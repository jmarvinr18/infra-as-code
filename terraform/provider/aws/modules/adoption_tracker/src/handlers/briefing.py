"""Triggers the leadership insight agent and records the outcome.

The agent itself is a LangGraph graph running on AgentCore Runtime; this is
only the thing that starts it — from the nightly EventBridge rule, or from
POST /v1/insights/regenerate when someone wants a fresh briefing during a demo.

Briefings are cached deliberately. The dashboard reads the newest row from
insight_briefings, so a page load costs a SELECT rather than a model
invocation.

When the runtime is not deployed yet, or the invocation fails, a row is still
written with status "unavailable". An empty panel with a timestamp is a
recoverable state; a panel showing yesterday's numbers as if they were today's
is not.
"""

import json
import os
import boto3  # noqa: E402
from botocore.config import Config  # noqa: E402

from common import (  # noqa: E402
    LOG,
    T_BRIEFINGS,
    T_CONFIG,
    authenticate,
    execute,
    handler_entrypoint,
    new_id,
    parse_body,
    response,
)

AGENT_RUNTIME_ARN = os.environ.get("AGENT_RUNTIME_ARN")
AGENT_QUALIFIER = os.environ.get("AGENT_RUNTIME_QUALIFIER", "DEFAULT")
BRIEFING_MODEL_ID = os.environ.get("BRIEFING_MODEL_ID", "")

_agentcore = None


def agentcore():
    global _agentcore
    if _agentcore is None:
        _agentcore = boto3.client(
            "bedrock-agentcore",
            config=Config(retries={"max_attempts": 3, "mode": "adaptive"}),
        )
    return _agentcore


def persist(agent_id, payload, status):
    briefing_id = new_id("brf")
    execute(
        f"""
        INSERT INTO {T_BRIEFINGS} (
            id, agent_id, summary, insight, recommendation, citations, model_id, status
        ) VALUES (
            :id, :agent_id, :summary, :insight, :recommendation,
            CAST(:citations AS jsonb), :model_id, :status
        )
        """,
        {
            "id": briefing_id,
            "agent_id": agent_id,
            "summary": payload.get("summary"),
            "insight": payload.get("insight"),
            "recommendation": payload.get("recommendation"),
            "citations": payload.get("citations") or [],
            "model_id": payload.get("model_id") or BRIEFING_MODEL_ID,
            "status": status,
        },
    )
    return briefing_id


def invoke_agent(agent_id):
    if not AGENT_RUNTIME_ARN:
        raise RuntimeError("No AgentCore runtime is configured for this deployment")

    result = agentcore().invoke_agent_runtime(
        agentRuntimeArn=AGENT_RUNTIME_ARN,
        qualifier=AGENT_QUALIFIER,
        payload=json.dumps({"agent_id": agent_id, "task": "generate_briefing"}).encode("utf-8"),
    )
    body = result.get("response")
    raw = body.read() if hasattr(body, "read") else body
    return json.loads(raw)


def generate_for(agent_id):
    try:
        payload = invoke_agent(agent_id)
    except Exception as exc:  # noqa: BLE001
        LOG.exception("Briefing generation failed for %s", agent_id)
        # Say nothing rather than say something wrong. A briefing a leader
        # might repeat to their own leadership has to be worth trusting, and a
        # stale one presented as current is worse than none.
        persist(
            agent_id,
            {
                "summary": "No briefing could be generated for this period.",
                "insight": None,
                "recommendation": None,
                "citations": [],
            },
            "unavailable",
        )
        return {"agent_id": agent_id, "status": "unavailable", "error": str(exc)}

    briefing_id = persist(agent_id, payload, payload.get("status") or "ok")
    return {"agent_id": agent_id, "status": "ok", "briefing_id": briefing_id}


def active_agents():
    rows = execute(f"SELECT agent_id FROM {T_CONFIG} WHERE is_active = TRUE")
    return [row["agent_id"] for row in rows]


def scheduled(event, context):
    """Nightly regeneration for every active agent."""
    results = [generate_for(agent_id) for agent_id in active_agents()]
    LOG.info("Scheduled briefing run: %s", results)
    return {"generated": results}


@handler_entrypoint
def on_demand(event, context):
    """POST /v1/insights/regenerate — the demo's regenerate control.

    Throttled hard at the API Gateway stage: one agent invocation per request
    is the most expensive thing this API can be asked to do.
    """
    body = parse_body(event)
    config = authenticate(event, body)
    result = generate_for(config["agent_id"])
    return response(200 if result["status"] == "ok" else 503, result)


def lambda_handler(event, context):
    # EventBridge sends its own event shape; API Gateway always sets version.
    if event.get("version") and event.get("requestContext"):
        return on_demand(event, context)
    return scheduled(event, context)
