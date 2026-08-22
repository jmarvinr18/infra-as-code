"""Bootstrap — schema creation, demo seeding, and agent registration.

This is the one function that lets a fresh deployment become usable without a
laptop, a bastion, a tunnel, or psql on anyone's PATH. Invoke it from the
Lambda console's Test tab and the database goes from empty to demo-ready.

Why the DDL lives here as Python rather than as the rendered schema.sql:

The rendered file is written to .build/ at apply time, outside src/, so it is
not in the deployment package. Writing it into src/ instead would create a
Terraform ordering problem — archive_file reads source_dir at plan time, before
local_file has written into it, so the first apply would package a stale or
missing schema. Building the statements from the same TABLE_* environment
variables the handlers read gives the identical no-drift guarantee without that
race: if a table is renamed in var.table_names, this file and the handlers move
together because neither one hardcodes a name.

The statements are a list rather than one blob because the Data API executes
exactly one statement per call.

Actions:
    {"action": "health"}            connectivity and extension check
    {"action": "migrate"}           create every table, index and extension
    {"action": "seed"}              load demo data shaped for the demo narrative
    {"action": "register_agent", "agent_id": "...", "threshold_minutes": 2}
    {"action": "reset", "confirm": "DELETE ALL DATA"}
"""

import hashlib
import json
import os
import random
import secrets
import uuid
from datetime import datetime, timedelta, timezone

from common import (  # noqa: E402
    DB_MODE,
    EMBEDDING_DIMENSION,
    LOG,
    T_BRIEFINGS,
    T_CONFIG,
    T_FEEDBACK,
    T_FIRST_USE,
    T_THEMES,
    T_USAGE,
    execute,
)


# ─────────────────────────────────────────────────────────────────────────────
# Schema
#
# Mirrors sql/schema.sql.tftpl statement for statement. Every one is idempotent,
# so running migrate twice is the normal case rather than a mistake.
# ─────────────────────────────────────────────────────────────────────────────

def schema_statements():
    dim = EMBEDDING_DIMENSION
    return [
        'CREATE EXTENSION IF NOT EXISTS vector',
        'CREATE EXTENSION IF NOT EXISTS "uuid-ossp"',

        f"""CREATE TABLE IF NOT EXISTS {T_CONFIG} (
            agent_id          TEXT PRIMARY KEY,
            display_name      TEXT,
            api_key_hash      TEXT        NOT NULL,
            threshold_days    INTEGER     NOT NULL DEFAULT 14,
            threshold_minutes INTEGER,
            platform          TEXT,
            is_active         BOOLEAN     NOT NULL DEFAULT TRUE,
            created_at        TIMESTAMPTZ NOT NULL DEFAULT now(),
            updated_at        TIMESTAMPTZ NOT NULL DEFAULT now()
        )""",

        f"""CREATE TABLE IF NOT EXISTS {T_USAGE} (
            id             BIGSERIAL PRIMARY KEY,
            event_id       TEXT        NOT NULL UNIQUE,
            agent_id       TEXT        NOT NULL,
            acf2_id        TEXT        NOT NULL,
            platform       TEXT        NOT NULL,
            business_group TEXT,
            division       TEXT,
            event_type     TEXT        NOT NULL DEFAULT 'invocation',
            occurred_at    TIMESTAMPTZ NOT NULL DEFAULT now(),
            metadata       JSONB       NOT NULL DEFAULT '{{}}'::jsonb,
            received_at    TIMESTAMPTZ NOT NULL DEFAULT now()
        )""",

        f"CREATE INDEX IF NOT EXISTS idx_{T_USAGE}_agent_time "
        f"ON {T_USAGE} (agent_id, occurred_at DESC)",

        f"CREATE INDEX IF NOT EXISTS idx_{T_USAGE}_org "
        f"ON {T_USAGE} (agent_id, business_group, division)",

        f"""CREATE TABLE IF NOT EXISTS {T_FIRST_USE} (
            agent_id       TEXT        NOT NULL,
            acf2_id        TEXT        NOT NULL,
            first_use_at   TIMESTAMPTZ NOT NULL DEFAULT now(),
            platform       TEXT,
            business_group TEXT,
            division       TEXT,
            PRIMARY KEY (agent_id, acf2_id)
        )""",

        f"""CREATE TABLE IF NOT EXISTS {T_FEEDBACK} (
            response_id       TEXT PRIMARY KEY,
            agent_id          TEXT        NOT NULL,
            acf2_id           TEXT        NOT NULL,
            sentiment         TEXT,
            time_saved        NUMERIC(8,2),
            barriers          TEXT,
            value_signals     JSONB       NOT NULL DEFAULT '{{}}'::jsonb,
            barrier_embedding vector({dim}),
            theme_id          TEXT,
            submitted_at      TIMESTAMPTZ NOT NULL DEFAULT now()
        )""",

        f"CREATE UNIQUE INDEX IF NOT EXISTS idx_{T_FEEDBACK}_agent_user "
        f"ON {T_FEEDBACK} (agent_id, acf2_id)",

        f"CREATE INDEX IF NOT EXISTS idx_{T_FEEDBACK}_unembedded "
        f"ON {T_FEEDBACK} (agent_id) "
        f"WHERE barrier_embedding IS NULL AND barriers IS NOT NULL",

        f"""CREATE TABLE IF NOT EXISTS {T_THEMES} (
            theme_id     TEXT PRIMARY KEY,
            agent_id     TEXT        NOT NULL,
            label        TEXT,
            centroid     vector({dim}) NOT NULL,
            member_count INTEGER     NOT NULL DEFAULT 0,
            generated_at TIMESTAMPTZ NOT NULL DEFAULT now()
        )""",

        f"CREATE INDEX IF NOT EXISTS idx_{T_THEMES}_agent_rank "
        f"ON {T_THEMES} (agent_id, member_count DESC)",

        # HNSW rather than IVFFlat: IVFFlat needs training rows before it beats
        # a sequential scan, and it cannot be built usefully on an empty table.
        f"CREATE INDEX IF NOT EXISTS idx_{T_THEMES}_centroid "
        f"ON {T_THEMES} USING hnsw (centroid vector_cosine_ops)",

        f"""CREATE TABLE IF NOT EXISTS {T_BRIEFINGS} (
            id             TEXT PRIMARY KEY,
            agent_id       TEXT        NOT NULL,
            summary        TEXT,
            insight        TEXT,
            recommendation TEXT,
            citations      JSONB       NOT NULL DEFAULT '[]'::jsonb,
            model_id       TEXT,
            status         TEXT        NOT NULL DEFAULT 'ok',
            generated_at   TIMESTAMPTZ NOT NULL DEFAULT now()
        )""",

        f"CREATE INDEX IF NOT EXISTS idx_{T_BRIEFINGS}_agent_time "
        f"ON {T_BRIEFINGS} (agent_id, generated_at DESC)",
    ]


def run_migrate():
    applied, failed = [], []

    for index, statement in enumerate(schema_statements()):
        label = " ".join(statement.split())[:70]
        try:
            execute(statement)
            applied.append(label)
        except Exception as exc:  # noqa: BLE001
            # Keep going. A missing extension privilege should not stop the
            # tables from being created — a partial result plus a clear list of
            # what failed is far more useful than one opaque error.
            LOG.error("statement %s failed: %s", index, exc)
            failed.append({"statement": label, "error": str(exc)})

    return {
        "applied": len(applied),
        "failed": failed,
        "db_mode": DB_MODE,
        "tables": [T_CONFIG, T_USAGE, T_FIRST_USE, T_FEEDBACK, T_THEMES, T_BRIEFINGS],
    }


# ─────────────────────────────────────────────────────────────────────────────
# Health
# ─────────────────────────────────────────────────────────────────────────────

def run_health():
    checks = {}

    try:
        execute("SELECT 1 AS ok")
        checks["connection"] = "ok"
    except Exception as exc:  # noqa: BLE001
        # Almost always one of: no VPC route to the database, a security group
        # that does not allow the Lambda's SG, or credentials that cannot be
        # resolved. The message is returned verbatim because this endpoint is
        # operator-facing and the detail is the point.
        return {"connection": "failed", "error": str(exc), "db_mode": DB_MODE}

    try:
        rows = execute("SELECT extname FROM pg_extension WHERE extname = 'vector'")
        checks["pgvector"] = "installed" if rows else "MISSING — run migrate"
    except Exception as exc:  # noqa: BLE001
        checks["pgvector"] = f"check failed: {exc}"

    for table in (T_CONFIG, T_USAGE, T_FIRST_USE, T_FEEDBACK, T_THEMES, T_BRIEFINGS):
        try:
            rows = execute(f"SELECT COUNT(*) AS n FROM {table}")
            checks[table] = f"{rows[0]['n']} rows"
        except Exception:  # noqa: BLE001
            checks[table] = "MISSING — run migrate"

    checks["db_mode"] = DB_MODE
    return checks


# ─────────────────────────────────────────────────────────────────────────────
# Agent registration
# ─────────────────────────────────────────────────────────────────────────────

def run_register_agent(body):
    agent_id = body.get("agent_id")
    if not agent_id:
        raise ValueError("agent_id is required")

    api_key = body.get("api_key") or secrets.token_urlsafe(32)
    key_hash = hashlib.sha256(api_key.encode("utf-8")).hexdigest()

    execute(
        f"""INSERT INTO {T_CONFIG} (
                agent_id, display_name, api_key_hash,
                threshold_days, threshold_minutes, platform
            ) VALUES (
                :agent_id, :display_name, :api_key_hash,
                :threshold_days, :threshold_minutes, :platform
            )
            ON CONFLICT (agent_id) DO UPDATE SET
                display_name      = EXCLUDED.display_name,
                api_key_hash      = EXCLUDED.api_key_hash,
                threshold_days    = EXCLUDED.threshold_days,
                threshold_minutes = EXCLUDED.threshold_minutes,
                platform          = EXCLUDED.platform,
                updated_at        = now()""",
        {
            "agent_id": agent_id,
            "display_name": body.get("display_name") or agent_id,
            "api_key_hash": key_hash,
            "threshold_days": int(body.get("threshold_days", 14)),
            "threshold_minutes": body.get("threshold_minutes"),
            "platform": body.get("platform"),
        },
    )

    LOG.info("registered agent %s", agent_id)
    return {
        "agent_id": agent_id,
        "api_key": api_key,
        "note": "Shown once and not recoverable — only its SHA-256 is stored. "
                "Put it in ADOPTION_TRACKER_API_KEY now.",
    }


# ─────────────────────────────────────────────────────────────────────────────
# Seed
#
# Shaped for the demo narrative rather than for realism. Three things have to be
# true when the dashboard comes up, or beat three of the demo has nothing to
# point at:
#
#   * one division is visibly lagging and flat
#   * one barrier clearly dominates the others
#   * enough history exists for a trend line to have a shape
# ─────────────────────────────────────────────────────────────────────────────

DIVISIONS = [
    # (business_group, division, users, events/user/day, still active?)
    ("SLGS", "DevSecOps", 14, 3.0, True),
    ("SLGS", "Engineering", 22, 2.4, True),
    ("SLGS", "Data & Analytics", 9, 1.8, True),
    ("Canada", "Operations", 11, 1.2, True),
    # The lagging one. Adoption stops after week two, which is what the
    # briefing should notice and name.
    ("Canada", "Claims", 18, 0.9, False),
]

BARRIERS = (
    # Deliberately repetitive in meaning, varied in wording. String matching
    # sees five different complaints; embedding and clustering sees one theme.
    ["The documentation was unclear about setup"] * 3
    + ["I couldn't find any documentation for this"] * 3
    + ["Docs are confusing and out of date"] * 2
    + ["Not sure where the getting-started guide lives"] * 2
    + ["I did not know this agent existed until a colleague mentioned it"] * 2
    + ["Responses are too slow for my workflow"]
    + ["It does not integrate with the tools I already use"]
)


def run_seed(body):
    agent_id = body.get("agent_id")
    if not agent_id:
        raise ValueError("agent_id is required — register the agent first")

    days = int(body.get("days", 30))
    now = datetime.now(timezone.utc)
    rng = random.Random(body.get("seed", 42))  # reproducible: same demo every time

    events = 0
    users = 0

    for bg, division, user_count, rate, still_active in DIVISIONS:
        for u in range(user_count):
            acf2 = f"{division[:3].lower()}{u:04d}"
            users += 1

            first_use = now - timedelta(days=rng.randint(days - 5, days))
            active_until = now if still_active else first_use + timedelta(days=14)

            execute(
                f"""INSERT INTO {T_FIRST_USE}
                        (agent_id, acf2_id, first_use_at, platform, business_group, division)
                    VALUES (:agent_id, :acf2_id, CAST(:first_use_at AS timestamptz),
                            :platform, :business_group, :division)
                    ON CONFLICT (agent_id, acf2_id) DO NOTHING""",
                {
                    "agent_id": agent_id,
                    "acf2_id": acf2,
                    "first_use_at": first_use.isoformat(),
                    "platform": "bedrock_agentcore",
                    "business_group": bg,
                    "division": division,
                },
            )

            day = first_use
            while day < active_until:
                for _ in range(int(rng.random() * rate * 2)):
                    occurred = day + timedelta(
                        hours=rng.randint(8, 18), minutes=rng.randint(0, 59)
                    )
                    if occurred > now:
                        continue
                    execute(
                        f"""INSERT INTO {T_USAGE} (
                                event_id, agent_id, acf2_id, platform, business_group,
                                division, event_type, occurred_at, metadata
                            ) VALUES (
                                :event_id, :agent_id, :acf2_id, :platform, :business_group,
                                :division, :event_type, CAST(:occurred_at AS timestamptz),
                                CAST(:metadata AS jsonb)
                            ) ON CONFLICT (event_id) DO NOTHING""",
                        {
                            "event_id": str(uuid.uuid4()),
                            "agent_id": agent_id,
                            "acf2_id": acf2,
                            "platform": "bedrock_agentcore",
                            "business_group": bg,
                            "division": division,
                            "event_type": "invocation",
                            "occurred_at": occurred.isoformat(),
                            "metadata": json.dumps({"seeded": True}),
                        },
                    )
                    events += 1
                day += timedelta(days=1)

    # Feedback from a subset. Only some users answer a survey — a 100% response
    # rate would be the least believable thing on the dashboard.
    responses = 0
    for index, barrier in enumerate(BARRIERS):
        bg, division, user_count, _, _ = DIVISIONS[index % len(DIVISIONS)]
        acf2 = f"{division[:3].lower()}{index % user_count:04d}"
        try:
            execute(
                f"""INSERT INTO {T_FEEDBACK} (
                        response_id, agent_id, acf2_id, sentiment, time_saved,
                        barriers, value_signals, submitted_at
                    ) VALUES (
                        :response_id, :agent_id, :acf2_id, :sentiment, :time_saved,
                        :barriers, CAST(:value_signals AS jsonb),
                        CAST(:submitted_at AS timestamptz)
                    ) ON CONFLICT (agent_id, acf2_id) DO NOTHING""",
                {
                    "response_id": str(uuid.uuid4()),
                    "agent_id": agent_id,
                    "acf2_id": acf2,
                    "sentiment": str(rng.randint(2, 5)),
                    "time_saved": round(rng.uniform(0.5, 6.0), 2),
                    "barriers": barrier,
                    "value_signals": json.dumps({"would_recommend": rng.random() > 0.3}),
                    "submitted_at": (now - timedelta(days=rng.randint(1, 10))).isoformat(),
                },
            )
            responses += 1
        except Exception as exc:  # noqa: BLE001
            LOG.warning("seed feedback skipped: %s", exc)

    return {
        "agent_id": agent_id,
        "users": users,
        "events": events,
        "feedback_responses": responses,
        "lagging_division": "Claims",
        "note": "Claims adoption stops after week two and documentation "
                "barriers dominate — that is what the briefing should find.",
    }


# ─────────────────────────────────────────────────────────────────────────────
# Reset
# ─────────────────────────────────────────────────────────────────────────────

def run_reset(body):
    # Guarded by an exact phrase because a fat-fingered console invocation
    # should not be able to empty the database.
    if body.get("confirm") != "DELETE ALL DATA":
        raise ValueError('Refusing to reset. Pass {"confirm": "DELETE ALL DATA"}.')

    cleared = []
    for table in (T_FEEDBACK, T_USAGE, T_FIRST_USE, T_THEMES, T_BRIEFINGS):
        execute(f"DELETE FROM {table}")
        cleared.append(table)

    return {"cleared": cleared, "note": f"{T_CONFIG} left intact — API keys survive a reset."}


# ─────────────────────────────────────────────────────────────────────────────
# Entrypoint
#
# Not wrapped in handler_entrypoint: this is invoked directly rather than
# through API Gateway, and an operator wants the real error rather than a
# sanitised 500.
# ─────────────────────────────────────────────────────────────────────────────

ACTIONS = {
    "health": lambda body: run_health(),
    "migrate": lambda body: run_migrate(),
    "seed": run_seed,
    "register_agent": run_register_agent,
    "reset": run_reset,
}


def handler(event, context=None):
    # Accepts a direct console invocation and an API Gateway request equally.
    if isinstance(event, dict) and "action" in event:
        body = event
    else:
        raw = (event or {}).get("body") or "{}"
        try:
            body = json.loads(raw)
        except (TypeError, json.JSONDecodeError):
            body = {}

    action = body.get("action", "health")

    if action not in ACTIONS:
        return {
            "ok": False,
            "error": f"Unknown action '{action}'",
            "available": sorted(ACTIONS),
        }

    LOG.info("bootstrap action=%s db_mode=%s", action, DB_MODE)

    try:
        return {"ok": True, "action": action, "result": ACTIONS[action](body)}
    except Exception as exc:  # noqa: BLE001
        LOG.exception("bootstrap action %s failed", action)
        return {"ok": False, "action": action, "error": str(exc)}


# Alias for the AWS default naming convention.
lambda_handler = handler
