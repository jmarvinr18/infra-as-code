"""POST /v1/feedback/check and POST /v1/feedback/submit.

Feedback is asked for once, a set time after a person's first use, and never
again once they have answered. Both halves of that are enforced in SQL rather
than in application state: the threshold is measured against ``first_use``, and
a unique index on (agent_id, acf2_id) in ``feedback_responses`` is what stops a
second survey.

The threshold is per-agent. ``threshold_minutes`` takes precedence over
``threshold_days`` when it is set, which is how a demo shows a survey firing
without waiting a fortnight — configuration on one agent, not a global switch
that changes behaviour for everybody.
"""

from common import (  # noqa: E402
    HttpError,
    LOG,
    T_CONFIG,
    T_FEEDBACK,
    T_FIRST_USE,
    authenticate,
    execute,
    handler_entrypoint,
    new_id,
    parse_body,
    require,
    response,
    send_to_dlq,
)

QUESTIONS = [
    {
        "id": "sentiment",
        "prompt": "Overall, how has this agent been for you?",
        "type": "choice",
        "options": ["positive", "neutral", "negative"],
    },
    {
        "id": "time_saved",
        "prompt": "Roughly how many hours has it saved you per week?",
        "type": "number",
    },
    {
        "id": "barriers",
        "prompt": "What has got in the way of using it more?",
        "type": "text",
    },
    {
        "id": "value_signals",
        "prompt": "Where has it helped most?",
        "type": "multi_choice",
        "options": ["speed", "quality", "learning", "consistency", "other"],
    },
]


def _threshold(config):
    """Minutes after first use before the survey is due.

    threshold_minutes exists for the demo and wins when set. It is stored per
    agent so switching it on for a demo agent leaves the real ones alone.
    """
    minutes = config.get("threshold_minutes")
    if minutes not in (None, ""):
        return int(minutes), "minutes"
    return int(config.get("threshold_days") or 14) * 24 * 60, "days"


@handler_entrypoint
def check(event, context):
    body = parse_body(event)
    config = authenticate(event, body)
    agent_id = config["agent_id"]
    acf2_id = require(body, "acf2_id")

    minutes, unit = _threshold(config)

    rows = execute(
        f"""
        SELECT
            f.first_use_at,
            EXTRACT(EPOCH FROM (now() - f.first_use_at)) / 60 AS minutes_since_first_use,
            EXISTS (
                SELECT 1 FROM {T_FEEDBACK} r
                WHERE r.agent_id = f.agent_id AND r.acf2_id = f.acf2_id
            ) AS already_answered
        FROM {T_FIRST_USE} f
        WHERE f.agent_id = :agent_id AND f.acf2_id = :acf2_id
        """,
        {"agent_id": agent_id, "acf2_id": acf2_id},
    )

    if not rows:
        return response(200, {"due": False, "reason": "no recorded first use"})

    row = rows[0]
    if row.get("already_answered") in (True, "true", 1):
        return response(200, {"due": False, "reason": "already answered"})

    elapsed = float(row.get("minutes_since_first_use") or 0)
    if elapsed < minutes:
        return response(
            200,
            {
                "due": False,
                "reason": "threshold not reached",
                "threshold_unit": unit,
                "minutes_remaining": round(minutes - elapsed, 1),
            },
        )

    return response(
        200,
        {
            "due": True,
            "threshold_unit": unit,
            "first_use_at": row.get("first_use_at"),
            "questions": QUESTIONS,
        },
    )


INSERT_RESPONSE = f"""
INSERT INTO {T_FEEDBACK} (
    response_id, agent_id, acf2_id, sentiment, time_saved, barriers, value_signals
) VALUES (
    :response_id, :agent_id, :acf2_id, :sentiment, :time_saved, :barriers,
    CAST(:value_signals AS jsonb)
)
ON CONFLICT (agent_id, acf2_id) DO NOTHING
RETURNING response_id
"""


@handler_entrypoint
def submit(event, context):
    body = parse_body(event)
    config = authenticate(event, body)
    agent_id = config["agent_id"]
    acf2_id = require(body, "acf2_id")

    sentiment = body.get("sentiment")
    if sentiment is not None and sentiment not in ("positive", "neutral", "negative"):
        raise HttpError(400, "'sentiment' must be positive, neutral or negative")

    time_saved = body.get("time_saved")
    if time_saved is not None:
        try:
            time_saved = float(time_saved)
        except (TypeError, ValueError):
            raise HttpError(400, "'time_saved' must be a number of hours")

    value_signals = body.get("value_signals") or {}
    if isinstance(value_signals, list):
        value_signals = {"selected": value_signals}
    if not isinstance(value_signals, dict):
        raise HttpError(400, "'value_signals' must be an object or an array")

    row = {
        "response_id": body.get("response_id") or new_id("fbk"),
        "agent_id": agent_id,
        "acf2_id": str(acf2_id),
        "sentiment": sentiment,
        "time_saved": time_saved,
        # Left unembedded on purpose. The embedding job picks it up on its next
        # run, which keeps a Bedrock call off the user's submit path.
        "barriers": body.get("barriers"),
        "value_signals": value_signals,
    }

    try:
        inserted = execute(INSERT_RESPONSE, row)
    except Exception as exc:  # noqa: BLE001
        LOG.exception("Feedback write failed for %s", row["response_id"])
        send_to_dlq(f"feedback insert failed: {exc}", row)
        raise HttpError(500, "Feedback could not be stored; it has been queued for retry")

    if not inserted:
        # Answering twice is not an error worth showing a user — the survey is
        # simply already done.
        return response(200, {"accepted": True, "duplicate": True})

    return response(200, {"accepted": True, "response_id": row["response_id"]})


def scheduled(event, context):
    """Daily sweep: who has crossed their threshold and not yet answered.

    The API is pull-based — an agent asks whether feedback is due for the user
    in front of it — so this does not send anything. It reports the size of the
    due population per agent, which is the number that tells you whether the
    survey is reaching people or quietly firing at nobody.
    """
    rows = execute(
        f"""
        SELECT
            c.agent_id,
            COUNT(*) AS due_users
        FROM {T_FIRST_USE} f
        JOIN {T_CONFIG} c ON c.agent_id = f.agent_id AND c.is_active = TRUE
        WHERE NOT EXISTS (
                SELECT 1 FROM {T_FEEDBACK} r
                WHERE r.agent_id = f.agent_id AND r.acf2_id = f.acf2_id
              )
          AND now() - f.first_use_at >= make_interval(
                mins => COALESCE(c.threshold_minutes, c.threshold_days * 24 * 60)
              )
        GROUP BY 1
        ORDER BY due_users DESC
        """
    )
    summary = {row["agent_id"]: int(row["due_users"]) for row in rows}
    LOG.info("Feedback due sweep: %s", summary)
    return {"due_by_agent": summary}


def lambda_handler(event, context):
    """Single entry point; the caller decides which half runs.

    EventBridge sends no requestContext, so a scheduled invocation is
    distinguishable from an HTTP one without inspecting the payload.
    """
    if not event.get("requestContext"):
        return scheduled(event, context)

    route = (event.get("requestContext", {}).get("http", {}).get("path")
             or event.get("rawPath") or "")
    if route.endswith("/submit"):
        return submit(event, context)
    return check(event, context)
