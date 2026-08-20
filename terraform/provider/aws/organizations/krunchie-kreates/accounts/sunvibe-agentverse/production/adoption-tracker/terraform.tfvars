# ─────────────────────────────────────────────────────────────────────────────
# AI Adoption & Feedback Tracker — production
#
# Applied together with ../terraform.tfvars, which carries the account values.
# ─────────────────────────────────────────────────────────────────────────────

name_prefix      = "adoption-tracker"
default_agent_id = "sunvibe-demo"

# ── Store ────────────────────────────────────────────────────────────────────
#
# min_capacity = 0 is what keeps an idle week near zero. Confirm the account
# actually permits it on the first apply — if it does not, raise this and say
# what the floor costs on the cost slide rather than repeating a
# scale-to-zero claim you can no longer defend.

create_aurora   = true
db_name         = "adoption"
db_min_capacity = 0
db_max_capacity = 2

# Direct 5432 access to the cluster, for psql or a migration runner. The Data
# API path needs nothing here, so this stays empty unless someone is debugging.
db_allowed_cidr_blocks = []
db_publicly_accessible = false

# ── Development store ────────────────────────────────────────────────────────
#
# Postgres + pgvector in Docker on one EC2 instance. It is the fallback for the
# week: if the Data API is unavailable for the chosen engine version, or a
# cluster-side quota bites, point the functions here and keep building.
#
# It is also the host a developer opens in TablePlus or DBeaver, which is why
# it has a public address at all.
#
# pgvector_ec2_allowed_cidr_blocks is the only thing standing in front of the
# database. Put the developer addresses in as /32 before applying.
#
#   Find yours:  curl -s https://checkip.amazonaws.com
#
# A Lambda outside the VPC has no fixed source address, so no narrow CIDR
# covers it. If the functions have to reach this host, that is a decision to
# open it to 0.0.0.0/0 for development data behind a 32-character generated
# password — write it down here rather than letting it happen quietly.

create_pgvector_ec2        = true
pgvector_ec2_instance_type = "t4g.small"

pgvector_ec2_allowed_cidr_blocks = [
  # "203.0.113.4/32",  # replace with the developer addresses
]

# Switching the functions over also needs a psycopg layer in lambda_layers —
# the driver is not in the Lambda runtime. The module refuses the apply
# otherwise rather than letting it fail on the first invocation.
use_pgvector_ec2_for_lambdas = false
lambda_layers                = []

# ── API ──────────────────────────────────────────────────────────────────────

throttling_burst_limit = 100
throttling_rate_limit  = 50
log_retention_in_days  = 14

# Set to the dashboard's origin once it exists. Null leaves CORS off, which is
# right while everything is curl and the SDK.
cors_allow_origins = null

# ── Feedback ─────────────────────────────────────────────────────────────────
#
# threshold_minutes is deliberately left null here. It is per-agent
# configuration in agent_config, set on the demo agent alone — a survey firing
# on stage should not mean every real agent's threshold changed too.

feedback_threshold_days    = 14
feedback_threshold_minutes = null

# ── Insight ──────────────────────────────────────────────────────────────────
#
# create_insight_agent stays false until the container image is actually in
# ECR. The runtime cannot start from an empty repository, and day six is a bad
# time to find that out. Sequence:
#
#   1. apply with create_insight_agent = false
#   2. terraform output -raw ecr_repository_url
#   3. build and push the LangGraph image to it
#   4. set create_insight_agent = true and apply again

create_ecr_repository = true
create_guardrail      = true
create_insight_agent  = false

embedding_model_id = "amazon.titan-embed-text-v2:0"
labelling_model_id = "anthropic.claude-3-5-haiku-20241022-v1:0"
briefing_model_id  = "anthropic.claude-3-5-sonnet-20241022-v2:0"

# Lower is stricter. Check it against the seed data — if unrelated barriers end
# up in one theme, tighten this before blaming the model.
cluster_distance_threshold = 0.35

# ── Scheduling ───────────────────────────────────────────────────────────────

briefing_schedule_expression       = "cron(0 18 * * ? *)" # 02:00 ap-southeast-1
feedback_check_schedule_expression = "cron(0 1 * * ? *)"  # 09:00 ap-southeast-1
embedding_schedule_expression      = "rate(1 hour)"
schedules_enabled                  = true

tags = {
  "Name"       = "adoption-tracker"
  "Client"     = "sunvibe-agentverse"
  "Created-by" = "terraform-jmr"
  "Hackathon"  = "agentverse-challenge-1"
}
