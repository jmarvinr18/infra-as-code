#!/bin/bash
#
# Applies the schema migration to whichever store this deployment is using.
#
# Terraform renders the migration from the module's template, so the table
# names here come from var.table_names and cannot drift from what the Lambdas
# read out of their environment. Every statement is idempotent — running this
# twice is the normal case, not a mistake, which is why tf-apply.sh calls it on
# every apply rather than only the first.
#
# Usage:  ./bootstrap-schema.sh [path/to/schema.sql]

set -euo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCHEMA="${1:-$HERE/.build/schema.sql}"

if [[ ! -f "$SCHEMA" ]]; then
  echo "No rendered schema at $SCHEMA — run terraform apply first." >&2
  exit 1
fi

tfout() { terraform -chdir="$HERE" output -raw "$1" 2>/dev/null || true; }

CLUSTER_ARN="$(tfout cluster_arn)"
SECRET_ARN="$(tfout db_secret_arn)"
DB_NAME="$(tfout db_name)"
REGION="$(tfout region)"
REGION="${REGION:-ap-southeast-1}"

# ─────────────────────────────────────────────────────────────────────────────
# No cluster means the EC2 pgvector host is the store. Its container already
# applied this same file from docker-entrypoint-initdb.d on first boot; this
# path is for re-applying after a schema change.
# ─────────────────────────────────────────────────────────────────────────────

if [[ -z "$CLUSTER_ARN" || "$CLUSTER_ARN" == "null" ]]; then
  echo "No Aurora cluster in this deployment — applying to the EC2 pgvector host."
  CONN="$(terraform -chdir="$HERE" output -raw pgvector_ec2_connection_string)"
  psql "$CONN" -v ON_ERROR_STOP=1 -f "$SCHEMA"
  echo "Schema applied to the EC2 host."
  exit 0
fi

# ─────────────────────────────────────────────────────────────────────────────
# Data API path. It takes one statement per call, so the file is split on
# semicolons. That is enough for this migration — it contains no functions or
# DO blocks with embedded semicolons. Add one and this needs revisiting.
#
# The first statement after an idle period may fail while a paused Serverless
# v2 cluster wakes up, so it is retried rather than treated as an outage.
# ─────────────────────────────────────────────────────────────────────────────

echo "Applying $SCHEMA to $CLUSTER_ARN"

STATEMENTS="$(mktemp)"
trap 'rm -f "$STATEMENTS"' EXIT

python3 - "$SCHEMA" > "$STATEMENTS" <<'PY'
import re
import sys

sql = open(sys.argv[1]).read()
sql = re.sub(r"--[^\n]*", "", sql)          # strip comments
for statement in sql.split(";"):
    statement = " ".join(statement.split())  # collapse to one line
    if statement:
        print(statement)
PY

run_statement() {
  local stmt="$1" attempt
  for attempt in 1 2 3 4 5; do
    if aws rds-data execute-statement \
        --region "$REGION" \
        --resource-arn "$CLUSTER_ARN" \
        --secret-arn "$SECRET_ARN" \
        --database "$DB_NAME" \
        --sql "$stmt" \
        --no-cli-pager >/dev/null 2>&1; then
      return 0
    fi
    echo "  retrying (cluster may be resuming), attempt $attempt"
    sleep $(( attempt * 5 ))
  done
  echo "FAILED: $stmt" >&2
  return 1
}

while IFS= read -r stmt; do
  [[ -z "$stmt" ]] && continue
  run_statement "$stmt"
  echo "  ok: $(printf '%.72s' "$stmt")"
done < "$STATEMENTS"

echo "Schema applied."
