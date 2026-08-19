-- Run once against the instance created by this stack.
--   psql "postgresql://postgres:<password>@<db_endpoint>/vectordb" -f sql/bootstrap.sql
--
-- Equivalent to calling POST /admin/init on the API.

CREATE EXTENSION IF NOT EXISTS vector;

CREATE TABLE IF NOT EXISTS documents (
    id         bigserial PRIMARY KEY,
    content    text NOT NULL,
    embedding  vector(1536) NOT NULL,
    created_at timestamptz NOT NULL DEFAULT now()
);

-- HNSW gives good recall without a training step. Cosine distance matches the
-- `1 - (embedding <=> query)` similarity the handler returns.
CREATE INDEX IF NOT EXISTS documents_embedding_idx
    ON documents USING hnsw (embedding vector_cosine_ops);

SELECT extversion AS pgvector_version FROM pg_extension WHERE extname = 'vector';
