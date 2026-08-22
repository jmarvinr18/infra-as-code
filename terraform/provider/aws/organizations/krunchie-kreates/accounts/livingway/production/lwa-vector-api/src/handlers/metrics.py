"""Read side: aggregates, themes, and the cached briefing.

This is also the agent's only door to the data. ``get_adoption_metrics`` and
``get_barrier_themes`` are tool calls onto ``/v1/metrics/adoption`` and
``/v1/themes`` — the insight agent has no database credentials of its own and
cannot query anything these routes do not return. That is what makes "the agent
cannot report on data its tools did not give it" a property of the deployment
rather than a line in a prompt.

The aggregates themselves are the reason this is Postgres. Adoption by business
group and division, active users per week, barriers ranked by frequency: one
GROUP BY each.
"""

from common import (  # noqa: E402
    ENVIRONMENT,
    T_BRIEFINGS,
    T_FEEDBACK,
    T_THEMES,
    T_USAGE,
    authenticate,
    execute,
    handler_entrypoint,
    query_params,
    response,
    request_path
)

DEFAULT_WINDOW_DAYS = 90
MAX_WINDOW_DAYS = 365


def _window(params):
    try:
        days = int(params.get("days", DEFAULT_WINDOW_DAYS))
    except (TypeError, ValueError):
        days = DEFAULT_WINDOW_DAYS
    return max(1, min(days, MAX_WINDOW_DAYS))


def adoption_by_org(agent_id, days):
    return execute(
        f"""
        SELECT
            COALESCE(business_group, 'unspecified') AS business_group,
            COALESCE(division, 'unspecified')       AS division,
            COUNT(DISTINCT acf2_id)                 AS active_users,
            COUNT(*)                                AS events
        FROM {T_USAGE}
        WHERE agent_id = :agent_id
          AND occurred_at >= now() - make_interval(days => :days)
        GROUP BY 1, 2
        ORDER BY active_users DESC, events DESC
        """,
        {"agent_id": agent_id, "days": days},
    )


def adoption_trend(agent_id, days):
    return execute(
        f"""
        SELECT
            date_trunc('week', occurred_at)::date AS week,
            COUNT(DISTINCT acf2_id)               AS active_users,
            COUNT(*)                              AS events
        FROM {T_USAGE}
        WHERE agent_id = :agent_id
          AND occurred_at >= now() - make_interval(days => :days)
        GROUP BY 1
        ORDER BY 1
        """,
        {"agent_id": agent_id, "days": days},
    )


def totals(agent_id, days):
    rows = execute(
        f"""
        SELECT
            COUNT(*)                        AS events,
            COUNT(DISTINCT acf2_id)         AS active_users,
            COUNT(DISTINCT platform)        AS platforms,
            MIN(occurred_at)                AS first_event_at,
            MAX(occurred_at)                AS last_event_at
        FROM {T_USAGE}
        WHERE agent_id = :agent_id
          AND occurred_at >= now() - make_interval(days => :days)
        """,
        {"agent_id": agent_id, "days": days},
    )
    return rows[0] if rows else {}


def by_platform(agent_id, days):
    return execute(
        f"""
        SELECT platform, COUNT(DISTINCT acf2_id) AS active_users, COUNT(*) AS events
        FROM {T_USAGE}
        WHERE agent_id = :agent_id
          AND occurred_at >= now() - make_interval(days => :days)
        GROUP BY 1
        ORDER BY events DESC
        """,
        {"agent_id": agent_id, "days": days},
    )


def barrier_themes(agent_id, limit=20):
    return execute(
        f"""
        SELECT theme_id, label, member_count, generated_at
        FROM {T_THEMES}
        WHERE agent_id = :agent_id AND label IS NOT NULL
        ORDER BY member_count DESC
        LIMIT :limit
        """,
        {"agent_id": agent_id, "limit": limit},
    )


def sentiment_breakdown(agent_id):
    return execute(
        f"""
        SELECT
            COALESCE(sentiment, 'unspecified') AS sentiment,
            COUNT(*)                           AS responses,
            ROUND(AVG(time_saved), 2)          AS avg_time_saved_hours
        FROM {T_FEEDBACK}
        WHERE agent_id = :agent_id
        GROUP BY 1
        ORDER BY responses DESC
        """,
        {"agent_id": agent_id},
    )


def latest_briefing(agent_id):
    rows = execute(
        f"""
        SELECT id, summary, insight, recommendation, citations, status, model_id, generated_at
        FROM {T_BRIEFINGS}
        WHERE agent_id = :agent_id
        ORDER BY generated_at DESC
        LIMIT 1
        """,
        {"agent_id": agent_id},
    )
    return rows[0] if rows else None


@handler_entrypoint
def lambda_handler(event, context):
    
    path = request_path(event)

    # Unauthenticated on purpose: it must answer while the database is paused,
    # because that is exactly when someone is checking whether the API is up.
    if path.endswith("/health"):
        return response(200, {"ok": True, "environment": ENVIRONMENT})

    params = query_params(event)
    config = authenticate(event, params)
    agent_id = config["agent_id"]
    days = _window(params)

    if path.endswith("/metrics/adoption"):
        return response(200, {"agent_id": agent_id, "window_days": days,
                              "adoption": adoption_by_org(agent_id, days)})

    if path.endswith("/metrics/trend"):
        return response(200, {"agent_id": agent_id, "window_days": days,
                              "trend": adoption_trend(agent_id, days)})

    if path.endswith("/themes"):
        return response(200, {"agent_id": agent_id, "themes": barrier_themes(agent_id)})

    # GET /v1/insights — everything the dashboard and the agent's tools need in
    # one round trip, plus whatever briefing is currently cached. Returning the
    # briefing here rather than generating it is the point: page loads must not
    # translate into agent invocations.
    briefing = latest_briefing(agent_id)
    return response(
        200,
        {
            "agent_id": agent_id,
            "window_days": days,
            "totals": totals(agent_id, days),
            "adoption": adoption_by_org(agent_id, days),
            "trend": adoption_trend(agent_id, days),
            "platforms": by_platform(agent_id, days),
            "sentiment": sentiment_breakdown(agent_id),
            "themes": barrier_themes(agent_id),
            # An absent briefing is an empty state, not an error — the panel
            # has to render on day one, before the agent has ever run.
            "briefing": briefing,
        },
    )
