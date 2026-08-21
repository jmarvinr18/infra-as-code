"""Scheduled job: embed free-text barriers, then cluster them into themes.

Two people writing "the docs are confusing" and "I couldn't find any
documentation" have reported one barrier, and no amount of string matching will
ever see that. So the text is embedded with Titan Text Embeddings v2 and
clustered by cosine distance inside Postgres, against centroids that already
exist. A barrier that falls within the threshold joins a theme and moves its
centroid; one that does not starts a new theme.

Naming happens once per run, in a single batched model call over the clusters
that still lack a label — not one call per response, and not by asking a model
to discover and name themes from a wall of raw text at the same time.
"""

import json
import os
import boto3  # noqa: E402
from botocore.config import Config  # noqa: E402

from common import (  # noqa: E402
    EMBEDDING_DIMENSION,
    LOG,
    T_FEEDBACK,
    T_THEMES,
    execute,
    new_id,
)

EMBEDDING_MODEL_ID = os.environ.get("EMBEDDING_MODEL_ID", "amazon.titan-embed-text-v2:0")
LABELLING_MODEL_ID = os.environ.get("LABELLING_MODEL_ID", "anthropic.claude-3-5-haiku-20241022-v1:0")
DISTANCE_THRESHOLD = float(os.environ.get("CLUSTER_DISTANCE_THRESHOLD", "0.35"))
BATCH_SIZE = int(os.environ.get("EMBEDDING_BATCH_SIZE", "100"))
LABEL_BATCH_SIZE = int(os.environ.get("LABEL_BATCH_SIZE", "20"))

_bedrock = None


def bedrock():
    global _bedrock
    if _bedrock is None:
        _bedrock = boto3.client(
            "bedrock-runtime",
            config=Config(retries={"max_attempts": 5, "mode": "adaptive"}),
        )
    return _bedrock


def embed(text):
    payload = {"inputText": text, "dimensions": EMBEDDING_DIMENSION, "normalize": True}
    result = bedrock().invoke_model(
        modelId=EMBEDDING_MODEL_ID,
        body=json.dumps(payload),
        accept="application/json",
        contentType="application/json",
    )
    return json.loads(result["body"].read())["embedding"]


def _vector_literal(values):
    """pgvector's text input format. Sent as a string and cast in SQL, because
    the Data API has no vector parameter type."""
    return "[" + ",".join(f"{v:.6f}" for v in values) + "]"


def pending(limit):
    return execute(
        f"""
        SELECT response_id, agent_id, barriers
        FROM {T_FEEDBACK}
        WHERE barrier_embedding IS NULL
          AND barriers IS NOT NULL
          AND length(trim(barriers)) > 0
        ORDER BY submitted_at
        LIMIT :limit
        """,
        {"limit": limit},
    )


def nearest_theme(agent_id, vector_literal):
    """Closest existing centroid, by cosine distance.

    `<=>` is pgvector's cosine-distance operator: 0 is identical, 1 is
    unrelated. The HNSW index on centroid is what keeps this cheap.
    """
    rows = execute(
        f"""
        SELECT theme_id, member_count,
               centroid <=> CAST(:embedding AS vector) AS distance
        FROM {T_THEMES}
        WHERE agent_id = :agent_id
        ORDER BY distance
        LIMIT 1
        """,
        {"agent_id": agent_id, "embedding": vector_literal},
    )
    return rows[0] if rows else None


def recentroid(theme_id):
    """Recompute a theme's centroid and size from the rows that belong to it.

    pgvector has no scalar-multiply operator, so the tempting incremental
    running-mean update does not actually work — `centroid * member_count` is
    not valid. avg(vector) is, and recomputing from members is correct by
    construction rather than only as long as nothing else touched the row.
    """
    execute(
        f"""
        UPDATE {T_THEMES} t
        SET centroid     = m.centroid,
            member_count = m.member_count,
            generated_at = now()
        FROM (
            SELECT AVG(barrier_embedding) AS centroid,
                   COUNT(*)               AS member_count
            FROM {T_FEEDBACK}
            WHERE theme_id = :theme_id AND barrier_embedding IS NOT NULL
        ) AS m
        WHERE t.theme_id = :theme_id AND m.member_count > 0
        """,
        {"theme_id": theme_id},
    )


def create_theme(agent_id, vector_literal):
    theme_id = new_id("thm")
    execute(
        f"""
        INSERT INTO {T_THEMES} (theme_id, agent_id, label, centroid, member_count)
        VALUES (:theme_id, :agent_id, NULL, CAST(:embedding AS vector), 1)
        """,
        {"theme_id": theme_id, "agent_id": agent_id, "embedding": vector_literal},
    )
    return theme_id


def label_unnamed_themes():
    """One model call for every theme still waiting for a name."""
    unnamed = execute(
        f"""
        SELECT t.theme_id, t.agent_id, t.member_count,
               (
                   SELECT string_agg(sample.barriers, ' | ')
                   FROM (
                       SELECT f.barriers
                       FROM {T_FEEDBACK} f
                       WHERE f.theme_id = t.theme_id
                       ORDER BY f.submitted_at
                       LIMIT 5
                   ) AS sample
               ) AS examples
        FROM {T_THEMES} t
        WHERE t.label IS NULL
        ORDER BY t.member_count DESC
        LIMIT :limit
        """,
        {"limit": LABEL_BATCH_SIZE},
    )
    if not unnamed:
        return 0

    clusters = [
        {"theme_id": row["theme_id"], "examples": (row.get("examples") or "")[:1200]}
        for row in unnamed
    ]

    prompt = (
        "Each cluster below groups verbatim comments about barriers to using an "
        "internal AI agent. Give each cluster a short, concrete label of three to "
        "six words naming the barrier itself — for example 'unclear documentation' "
        "or 'slow response times'. Do not editorialise and do not invent a barrier "
        "the comments do not mention.\n\n"
        "Reply with JSON only, in the form "
        '{"labels": [{"theme_id": "...", "label": "..."}]}.\n\n'
        + json.dumps(clusters, indent=2)
    )

    result = bedrock().converse(
        modelId=LABELLING_MODEL_ID,
        messages=[{"role": "user", "content": [{"text": prompt}]}],
        inferenceConfig={"maxTokens": 1024, "temperature": 0},
    )
    text = result["output"]["message"]["content"][0]["text"]

    try:
        start, end = text.index("{"), text.rindex("}") + 1
        labels = json.loads(text[start:end])["labels"]
    except (ValueError, KeyError):
        LOG.warning("Could not parse labels from the model response; leaving them for the next run")
        return 0

    updated = 0
    for item in labels:
        label = (item.get("label") or "").strip()
        if not label:
            continue
        execute(
            f"UPDATE {T_THEMES} SET label = :label, generated_at = now() WHERE theme_id = :theme_id",
            {"label": label[:120], "theme_id": item["theme_id"]},
        )
        updated += 1
    return updated


def lambda_handler(event, context):
    rows = pending(BATCH_SIZE)
    embedded = 0
    new_themes = 0

    for row in rows:
        try:
            literal = _vector_literal(embed(row["barriers"]))
        except Exception:  # noqa: BLE001 — one bad row must not stop the batch
            LOG.exception("Embedding failed for %s", row["response_id"])
            continue

        near = nearest_theme(row["agent_id"], literal)
        if near and float(near["distance"]) <= DISTANCE_THRESHOLD:
            theme_id = near["theme_id"]
        else:
            theme_id = create_theme(row["agent_id"], literal)
            new_themes += 1

        # The row is written before the centroid is recomputed, because the
        # recomputation averages over rows that already carry this theme_id.
        execute(
            f"""
            UPDATE {T_FEEDBACK}
            SET barrier_embedding = CAST(:embedding AS vector), theme_id = :theme_id
            WHERE response_id = :response_id
            """,
            {"embedding": literal, "theme_id": theme_id, "response_id": row["response_id"]},
        )
        recentroid(theme_id)
        embedded += 1

    labelled = label_unnamed_themes()

    summary = {
        "considered": len(rows),
        "embedded": embedded,
        "new_themes": new_themes,
        "labelled": labelled,
    }
    LOG.info("Embedding run: %s", summary)
    return summary
