"""POST /v1/usage — record a batch of usage events.

The contract is a batch from the start (``{"events": [...]}``) because the SDK
buffers, and a per-event endpoint would turn one agent invocation into a dozen
round trips.

Two properties matter more than anything else in here:

Duplicate events cannot double-count. ``event_id`` is UNIQUE and every insert
is ``ON CONFLICT DO NOTHING``, so a retried batch is a no-op rather than an
inflated adoption number. The response reports accepted and duplicate counts
separately so a caller can see the difference.

A failed write is not lost. If the insert raises, the batch goes to the DLQ
before the error is returned, so the events are still recoverable.
"""

from common import (  # noqa: E402
    HttpError,
    LOG,
    T_FIRST_USE,
    T_USAGE,
    authenticate,
    execute,
    handler_entrypoint,
    new_id,
    now_iso,
    parse_body,
    response,
    send_to_dlq,
)

MAX_BATCH = 500


def _normalise(event, agent_id):
    if not isinstance(event, dict):
        raise HttpError(400, "Each entry in 'events' must be an object")

    acf2_id = event.get("acf2_id") or event.get("user_id")
    if not acf2_id:
        raise HttpError(400, "Each event needs an 'acf2_id'")

    occurred_at = event.get("occurred_at") or now_iso()
    metadata = event.get("metadata") or {}
    if not isinstance(metadata, dict):
        raise HttpError(400, "'metadata' must be an object")

    return {
        # A caller that supplies no event_id gets one, and therefore gets no
        # idempotency — that is the caller's choice, and the SDK always sends one.
        "event_id": event.get("event_id") or new_id("evt"),
        "agent_id": event.get("agent_id") or agent_id,
        "acf2_id": str(acf2_id),
        "platform": event.get("platform") or "unknown",
        "business_group": event.get("business_group"),
        "division": event.get("division"),
        "event_type": event.get("event_type") or "invocation",
        "occurred_at": occurred_at,
        "metadata": metadata,
    }


INSERT_EVENT = f"""
INSERT INTO {T_USAGE} (
    event_id, agent_id, acf2_id, platform, business_group,
    division, event_type, occurred_at, metadata
) VALUES (
    :event_id, :agent_id, :acf2_id, :platform, :business_group,
    :division, :event_type, CAST(:occurred_at AS timestamptz), CAST(:metadata AS jsonb)
)
ON CONFLICT (event_id) DO NOTHING
RETURNING event_id
"""

# The first-use date is what every feedback threshold counts from. Letting a
# later event overwrite it would push the date forward on every invocation and
# no survey would ever come due — hence DO NOTHING rather than an upsert.
INSERT_FIRST_USE = f"""
INSERT INTO {T_FIRST_USE} (
    agent_id, acf2_id, first_use_at, platform, business_group, division
) VALUES (
    :agent_id, :acf2_id, CAST(:occurred_at AS timestamptz), :platform, :business_group, :division
)
ON CONFLICT (agent_id, acf2_id) DO NOTHING
"""


@handler_entrypoint
def lambda_handler(event, context):
    body = parse_body(event)
    config = authenticate(event, body)
    agent_id = config["agent_id"]

    events = body.get("events")
    if events is None:
        raise HttpError(400, "Body must contain an 'events' array")
    if not isinstance(events, list):
        raise HttpError(400, "'events' must be an array")
    if not events:
        return response(200, {"accepted": 0, "duplicates": 0, "events": []})
    if len(events) > MAX_BATCH:
        raise HttpError(400, f"Batch too large; the maximum is {MAX_BATCH} events")

    rows = [_normalise(e, agent_id) for e in events]

    accepted, duplicates = [], 0
    for row in rows:
        try:
            inserted = execute(INSERT_EVENT, row)
            if inserted:
                accepted.append(row["event_id"])
                execute(INSERT_FIRST_USE, row)
            else:
                duplicates += 1
        except Exception as exc:  # noqa: BLE001
            LOG.exception("Write failed for %s", row["event_id"])
            send_to_dlq(f"usage insert failed: {exc}", row)
            raise HttpError(
                500,
                "Some events could not be stored; they have been queued for retry",
                f"{len(accepted)} of {len(rows)} written before the failure",
            )

    return response(
        200,
        {
            "accepted": len(accepted),
            "duplicates": duplicates,
            "events": accepted,
        },
    )
