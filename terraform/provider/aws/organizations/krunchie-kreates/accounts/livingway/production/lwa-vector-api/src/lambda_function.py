"""HTTP API handler backed by RDS Postgres with pgvector.

Routes (see main.tf):
    GET  /health       liveness, plus a database probe when a driver is present
    POST /documents    store {"content": str, "embedding": [float, ...]}
    POST /search       nearest neighbours for {"embedding": [...], "top_k": int}
    POST /admin/init   create the vector extension and the demo table (IAM auth)

The Python runtime ships no Postgres driver. Attach a psycopg layer (see
README.md) or every database-backed route returns 501.
"""

import json
import logging
import os

logger = logging.getLogger()
logger.setLevel(logging.INFO)

try:
    import psycopg

    DRIVER = "psycopg"
except ImportError:  # pragma: no cover - depends on the attached layer
    psycopg = None
    DRIVER = None

TABLE = os.environ.get("VECTOR_TABLE", "documents")
EMBEDDING_DIM = int(os.environ.get("EMBEDDING_DIM", "1536"))

_password_cache = None


def _password():
    """Read the master password from the environment, or from Secrets Manager
    when RDS owns it."""
    global _password_cache

    direct = os.environ.get("DB_PASSWORD")
    if direct:
        return direct

    if _password_cache is None:
        import boto3

        secret_arn = os.environ["DB_SECRET_ARN"]
        client = boto3.client("secretsmanager")
        secret = client.get_secret_value(SecretId=secret_arn)
        _password_cache = json.loads(secret["SecretString"])["password"]

    return _password_cache


def _connect():
    return psycopg.connect(
        host=os.environ["DB_HOST"],
        port=int(os.environ.get("DB_PORT", "5432")),
        dbname=os.environ["DB_NAME"],
        user=os.environ["DB_USER"],
        password=_password(),
        connect_timeout=5,
        sslmode="require",
    )


def _response(status, body):
    return {
        "statusCode": status,
        "headers": {"content-type": "application/json"},
        "body": json.dumps(body),
    }


def _vector_literal(values):
    return "[" + ",".join(str(float(v)) for v in values) + "]"


# ── Route handlers ───────────────────────────────────────────────────────────


def health(_body):
    if psycopg is None:
        return _response(200, {"status": "ok", "database": "no driver attached"})

    with _connect() as conn, conn.cursor() as cur:
        cur.execute("SELECT 1")
        cur.fetchone()
        cur.execute("SELECT extname FROM pg_extension WHERE extname = 'vector'")
        has_vector = cur.fetchone() is not None

    return _response(200, {"status": "ok", "database": "reachable", "pgvector": has_vector})


def admin_init(_body):
    with _connect() as conn, conn.cursor() as cur:
        cur.execute("CREATE EXTENSION IF NOT EXISTS vector")
        cur.execute(
            f"""
            CREATE TABLE IF NOT EXISTS {TABLE} (
                id         bigserial PRIMARY KEY,
                content    text NOT NULL,
                embedding  vector({EMBEDDING_DIM}) NOT NULL,
                created_at timestamptz NOT NULL DEFAULT now()
            )
            """
        )
        cur.execute(
            f"""
            CREATE INDEX IF NOT EXISTS {TABLE}_embedding_idx
            ON {TABLE} USING hnsw (embedding vector_cosine_ops)
            """
        )
        conn.commit()

    return _response(200, {"initialized": True, "table": TABLE, "dimensions": EMBEDDING_DIM})


def store_document(body):
    content = body.get("content")
    embedding = body.get("embedding")
    if not content or not embedding:
        return _response(400, {"error": "content and embedding are required"})
    if len(embedding) != EMBEDDING_DIM:
        return _response(
            400, {"error": f"embedding must have {EMBEDDING_DIM} dimensions, got {len(embedding)}"}
        )

    with _connect() as conn, conn.cursor() as cur:
        cur.execute(
            f"INSERT INTO {TABLE} (content, embedding) VALUES (%s, %s::vector) RETURNING id",
            (content, _vector_literal(embedding)),
        )
        row_id = cur.fetchone()[0]
        conn.commit()

    return _response(201, {"id": row_id})


def search(body):
    embedding = body.get("embedding")
    if not embedding:
        return _response(400, {"error": "embedding is required"})

    top_k = min(int(body.get("top_k", 5)), 100)

    with _connect() as conn, conn.cursor() as cur:
        cur.execute(
            f"""
            SELECT id, content, 1 - (embedding <=> %s::vector) AS similarity
            FROM {TABLE}
            ORDER BY embedding <=> %s::vector
            LIMIT %s
            """,
            (_vector_literal(embedding), _vector_literal(embedding), top_k),
        )
        results = [
            {"id": row[0], "content": row[1], "similarity": float(row[2])} for row in cur.fetchall()
        ]

    return _response(200, {"results": results})


ROUTES = {
    "GET /health": health,
    "POST /admin/init": admin_init,
    "POST /documents": store_document,
    "POST /search": search,
}


def lambda_handler(event, _context):
    route_key = event.get("routeKey", "")
    handler = ROUTES.get(route_key)

    if handler is None:
        return _response(404, {"error": f"no handler for route {route_key!r}"})

    if psycopg is None and route_key != "GET /health":
        return _response(
            501,
            {"error": "no Postgres driver available; attach a psycopg layer to this function"},
        )

    try:
        body = json.loads(event["body"]) if event.get("body") else {}
    except json.JSONDecodeError:
        return _response(400, {"error": "request body must be valid JSON"})

    try:
        return handler(body)
    except Exception:
        logger.exception("route %s failed", route_key)
        return _response(500, {"error": "internal error"})
