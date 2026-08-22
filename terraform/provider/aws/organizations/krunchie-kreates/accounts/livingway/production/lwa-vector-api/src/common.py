"""Shared plumbing for every handler in this stack.

Two things live here that are worth reading before the handlers:

`execute` hides which store is behind the call. In ``data_api`` mode it signs
an HTTPS request to the RDS Data API, which is why none of these functions are
attached to a VPC — no ENI cold start, no NAT gateway, and no way for a burst
of concurrent invocations to exhaust ``max_connections``. In ``ec2`` mode it
opens an ordinary psycopg connection to the development Docker host, for the
week when something about the cluster is blocking and the work has to continue
anyway. The SQL is identical either way.

`authenticate` resolves the caller's agent from a hashed API key. The key is
never stored, only its SHA-256, so a database dump does not hand over working
credentials.
"""

import hashlib
import hmac
import json
import logging
import os
import time
import uuid
from datetime import datetime, timezone

import boto3
from botocore.config import Config

LOG = logging.getLogger()
LOG.setLevel(os.environ.get("LOG_LEVEL", "INFO"))

DB_MODE = os.environ.get("DB_MODE", "data_api")
DB_NAME = os.environ.get("DB_NAME", "adoption")
DB_CLUSTER_ARN = os.environ.get("DB_CLUSTER_ARN")
DB_SECRET_ARN = os.environ.get("DB_SECRET_ARN")
DEFAULT_AGENT_ID = os.environ.get("DEFAULT_AGENT_ID", "default")
ENVIRONMENT = os.environ.get("ENVIRONMENT", "production")
DLQ_URL = os.environ.get("DLQ_URL")

EMBEDDING_DIMENSION = int(os.environ.get("EMBEDDING_DIMENSION", "1024"))

T_USAGE = os.environ.get("TABLE_USAGE_EVENTS", "usage_events")
T_FIRST_USE = os.environ.get("TABLE_FIRST_USE", "first_use")
T_FEEDBACK = os.environ.get("TABLE_FEEDBACK_RESPONSES", "feedback_responses")
T_THEMES = os.environ.get("TABLE_BARRIER_THEMES", "barrier_themes")
T_BRIEFINGS = os.environ.get("TABLE_INSIGHT_BRIEFINGS", "insight_briefings")
T_CONFIG = os.environ.get("TABLE_AGENT_CONFIG", "agent_config")

# Retries are adaptive because the Data API answers with a 400-class
# DatabaseResumingException while a paused Serverless v2 cluster wakes up. The
# first call after an idle period is expected to fail and be retried; without
# this the first request of the morning looks like an outage.
_BOTO_CONFIG = Config(retries={"max_attempts": 8, "mode": "adaptive"})

_rds = None
_sqs = None

def request_path(event):
    """Path across HTTP API (2.0), REST API (1.0) and ALB events. """
    http = (event.get("requestContext") or {}).get("http") or {}
    return http.get("path") or event.get("rawPath") or event.get("path") or ""

def rds_data():
    global _rds
    if _rds is None:
        _rds = boto3.client("rds-data", config=_BOTO_CONFIG)
    return _rds


def sqs():
    global _sqs
    if _sqs is None:
        _sqs = boto3.client("sqs", config=_BOTO_CONFIG)
    return _sqs


# ─────────────────────────────────────────────────────────────────────────────
# HTTP
# ─────────────────────────────────────────────────────────────────────────────


class HttpError(Exception):
    """Raised with a status a caller should actually see."""

    def __init__(self, status, message, detail=None):
        super().__init__(message)
        self.status = status
        self.message = message
        self.detail = detail


def response(status, body):
    return {
        "statusCode": status,
        "headers": {"content-type": "application/json"},
        "body": json.dumps(body, default=_json_default),
    }


def _json_default(value):
    if isinstance(value, datetime):
        return value.isoformat()
    return str(value)


def parse_body(event):
    raw = event.get("body") or "{}"
    if event.get("isBase64Encoded"):
        import base64

        raw = base64.b64decode(raw).decode("utf-8")
    try:
        parsed = json.loads(raw)
    except json.JSONDecodeError as exc:
        raise HttpError(400, "Request body is not valid JSON", str(exc))
    if not isinstance(parsed, dict):
        raise HttpError(400, "Request body must be a JSON object")
    return parsed


def header(event, name, default=None):
    headers = {k.lower(): v for k, v in (event.get("headers") or {}).items()}
    return headers.get(name.lower(), default)


def query_params(event):
    return event.get("queryStringParameters") or {}


def handler_entrypoint(fn):
    """Turn raised HttpErrors into responses and anything else into a 500.

    A handler that raises past this decorator would return API Gateway's own
    error page, which tells the caller nothing. Unexpected failures are logged
    with a stack trace and answered with an opaque body — the detail belongs in
    CloudWatch, not in the response.
    """

    def wrapper(event, context):
        try:
            return fn(event, context)
        except HttpError as exc:
            LOG.warning("%s %s (%s)", exc.status, exc.message, exc.detail)
            body = {"error": exc.message}
            if exc.detail:
                body["detail"] = exc.detail
            return response(exc.status, body)
        except Exception:  # noqa: BLE001 — the boundary is the point
            LOG.exception("Unhandled error")
            return response(500, {"error": "Internal error"})

    return wrapper


# ─────────────────────────────────────────────────────────────────────────────
# Database
# ─────────────────────────────────────────────────────────────────────────────


def _data_api_param(name, value):
    if value is None:
        return {"name": name, "value": {"isNull": True}}
    if isinstance(value, bool):
        return {"name": name, "value": {"booleanValue": value}}
    if isinstance(value, int):
        return {"name": name, "value": {"longValue": value}}
    if isinstance(value, float):
        return {"name": name, "value": {"doubleValue": value}}
    if isinstance(value, (dict, list)):
        return {"name": name, "value": {"stringValue": json.dumps(value)}}
    return {"name": name, "value": {"stringValue": str(value)}}


def _data_api_value(field):
    for key in ("stringValue", "longValue", "doubleValue", "booleanValue", "blobValue"):
        if key in field:
            return field[key]
    if field.get("isNull"):
        return None
    if "arrayValue" in field:
        return field["arrayValue"]
    return None


def _execute_data_api(sql, params):
    result = rds_data().execute_statement(
        resourceArn=DB_CLUSTER_ARN,
        secretArn=DB_SECRET_ARN,
        database=DB_NAME,
        sql=sql,
        parameters=[_data_api_param(k, v) for k, v in (params or {}).items()],
        includeResultMetadata=True,
    )
    columns = [c["name"] for c in result.get("columnMetadata", [])]
    rows = []
    for record in result.get("records", []):
        rows.append(dict(zip(columns, (_data_api_value(f) for f in record))))
    return rows


def _execute_psycopg(sql, params):
    # Only imported on the development path. It is not in the Lambda runtime,
    # so ec2 mode needs a psycopg layer attached — which is exactly why this
    # import is here and not at the top of the file.
    import psycopg
    from psycopg.rows import dict_row

    conninfo = (
        f"host={os.environ['DB_HOST']} port={os.environ.get('DB_PORT', '5432')} "
        f"dbname={DB_NAME} user={os.environ['DB_USER']} "
        f"password={os.environ['DB_PASSWORD']} connect_timeout=5"
    )
    with psycopg.connect(conninfo, row_factory=dict_row, autocommit=True) as conn:
        with conn.cursor() as cur:
            cur.execute(sql, params or {})
            if cur.description is None:
                return []
            return [dict(row) for row in cur.fetchall()]


def execute(sql, params=None):
    """Run one statement against whichever store this deployment is using.

    Named parameters (``:name``) work identically in both modes — the Data API
    takes them natively and psycopg accepts the same ``%(name)s``-equivalent
    when given a mapping, so the SQL in the handlers is written once.
    """
    if DB_MODE == "ec2":
        # psycopg wants %(name)s where the Data API wants :name. The
        # lookbehind is load-bearing: without it this also rewrites Postgres's
        # :: cast operator, turning `occurred_at::date` into nonsense.
        import re

        translated = re.sub(r"(?<!:):(\w+)", r"%(\1)s", sql)
        return _execute_psycopg(translated, params)
    return _execute_data_api(sql, params)


def send_to_dlq(reason, payload):
    """Park a write we could not complete somewhere a human will find it.

    A synchronous API Gateway invocation has no automatic dead-letter path —
    Lambda's own dead_letter_config only covers asynchronous invocations. So
    the failure is pushed here explicitly rather than disappearing into a log
    line nobody reads.
    """
    if not DLQ_URL:
        LOG.error("No DLQ configured; dropping failed write: %s", reason)
        return False
    try:
        sqs().send_message(
            QueueUrl=DLQ_URL,
            MessageBody=json.dumps(
                {
                    "reason": reason,
                    "payload": payload,
                    "environment": ENVIRONMENT,
                    "failed_at": now_iso(),
                },
                default=_json_default,
            ),
        )
        return True
    except Exception:  # noqa: BLE001
        LOG.exception("Could not reach the DLQ either")
        return False


# ─────────────────────────────────────────────────────────────────────────────
# Auth
# ─────────────────────────────────────────────────────────────────────────────


def hash_api_key(key):
    return hashlib.sha256(key.encode("utf-8")).hexdigest()


def authenticate(event, body=None):
    """Resolve the calling agent from its API key, or raise 401.

    The key arrives in ``x-api-key``; the agent may be named in ``x-agent-id``
    or in the body. Comparison is against a stored SHA-256 and uses a constant
    time compare, so a wrong key cannot be narrowed down by timing the response.
    """
    api_key = header(event, "x-api-key")
    if not api_key:
        raise HttpError(401, "Missing x-api-key header")

    agent_id = header(event, "x-agent-id") or (body or {}).get("agent_id") or DEFAULT_AGENT_ID

    rows = execute(
        f"""
        SELECT agent_id, api_key_hash, threshold_days, threshold_minutes, is_active
        FROM {T_CONFIG}
        WHERE agent_id = :agent_id
        """,
        {"agent_id": agent_id},
    )
    if not rows:
        raise HttpError(401, "Unknown agent or invalid API key")

    config = rows[0]
    if not hmac.compare_digest(str(config["api_key_hash"]), hash_api_key(api_key)):
        raise HttpError(401, "Unknown agent or invalid API key")
    if config.get("is_active") is False:
        raise HttpError(403, "Agent is disabled")

    return config


# ─────────────────────────────────────────────────────────────────────────────
# Odds and ends
# ─────────────────────────────────────────────────────────────────────────────


def now_iso():
    return datetime.now(timezone.utc).isoformat()


def new_id(prefix):
    return f"{prefix}_{uuid.uuid4().hex}"


def require(body, field):
    value = body.get(field)
    if value in (None, ""):
        raise HttpError(400, f"Field '{field}' is required")
    return value


def timed(label):
    start = time.time()

    def done():
        LOG.info("%s took %.0fms", label, (time.time() - start) * 1000)

    return done
