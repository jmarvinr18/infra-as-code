#!/bin/bash
#
# Issues an API key for one agent and registers its hash.
#
# The key is printed once and never stored. What lands in agent_config is a
# SHA-256 of it, so a database dump does not hand anybody working credentials —
# and losing the key means issuing a new one, not recovering the old one.
#
# Usage:
#   ./issue-api-key.sh <agent_id> [threshold_days] [threshold_minutes]
#
# threshold_minutes is the demo setting: a survey cannot become due fourteen
# days into a stage slot. Set it on the demo agent only and every real agent
# keeps counting in days.
#
#   ./issue-api-key.sh sunvibe-demo 14 2

set -euo pipefail

AGENT_ID="${1:?usage: issue-api-key.sh <agent_id> [threshold_days] [threshold_minutes]}"
THRESHOLD_DAYS="${2:-14}"
THRESHOLD_MINUTES="${3:-}"

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
tfout() { terraform -chdir="$HERE" output -raw "$1" 2>/dev/null || true; }

CLUSTER_ARN="$(tfout cluster_arn)"
SECRET_ARN="$(tfout db_secret_arn)"
DB_NAME="$(tfout db_name)"
REGION="$(tfout region)"
REGION="${REGION:-ap-southeast-1}"
TABLE="$(terraform -chdir="$HERE" output -json table_names | python3 -c 'import json,sys; print(json.load(sys.stdin)["agent_config"])')"

API_KEY="$(python3 -c 'import secrets; print(secrets.token_urlsafe(32))')"
API_KEY_HASH="$(printf '%s' "$API_KEY" | shasum -a 256 | cut -d" " -f1)"

MINUTES_SQL="NULL"
if [[ -n "$THRESHOLD_MINUTES" ]]; then
  MINUTES_SQL="$THRESHOLD_MINUTES"
fi

SQL="INSERT INTO ${TABLE} (agent_id, api_key_hash, threshold_days, threshold_minutes, is_active)
     VALUES ('${AGENT_ID}', '${API_KEY_HASH}', ${THRESHOLD_DAYS}, ${MINUTES_SQL}, TRUE)
     ON CONFLICT (agent_id) DO UPDATE
     SET api_key_hash = EXCLUDED.api_key_hash,
         threshold_days = EXCLUDED.threshold_days,
         threshold_minutes = EXCLUDED.threshold_minutes,
         is_active = TRUE,
         updated_at = now()"

if [[ -n "$CLUSTER_ARN" && "$CLUSTER_ARN" != "null" ]]; then
  aws rds-data execute-statement \
    --region "$REGION" \
    --resource-arn "$CLUSTER_ARN" \
    --secret-arn "$SECRET_ARN" \
    --database "$DB_NAME" \
    --sql "$SQL" \
    --no-cli-pager >/dev/null
else
  psql "$(terraform -chdir="$HERE" output -raw pgvector_ec2_connection_string)" \
    -v ON_ERROR_STOP=1 -c "$SQL"
fi

cat <<SUMMARY

Agent registered: ${AGENT_ID}
  threshold_days:    ${THRESHOLD_DAYS}
  threshold_minutes: ${THRESHOLD_MINUTES:-none}

API key — shown once, not recoverable:

  ${API_KEY}

Use it:

  export ADOPTION_TRACKER_AGENT_ID=${AGENT_ID}
  export ADOPTION_TRACKER_API_KEY=${API_KEY}

  curl -X POST "\$(terraform -chdir=${HERE} output -raw api_endpoint)/v1/usage" \\
    -H "x-api-key: \$ADOPTION_TRACKER_API_KEY" \\
    -H "x-agent-id: \$ADOPTION_TRACKER_AGENT_ID" \\
    -H "content-type: application/json" \\
    -d '{"events":[{"event_id":"evt-1","acf2_id":"abc1234","platform":"bedrock_agentcore","business_group":"SLGS","division":"DevSecOps"}]}'

SUMMARY
