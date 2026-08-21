# ─────────────────────────────────────────────────────────────────────────────
# AI Adoption & Feedback Tracker — Agent Verse hackathon, challenge #1.
#
# Everything is in the module; this root supplies the account, the region and
# the values that differ between deployments. That split is the point of
# US-1.4: another team copies the module block below into their own repo,
# changes name_prefix and table_names, and gets a working second deployment
# without editing any of the module's code.
# ─────────────────────────────────────────────────────────────────────────────

data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

module "adoption_tracker" {
  source = "../../../../../../modules/adoption_tracker"

  name_prefix      = var.name_prefix
  environment      = var.environment
  default_agent_id = var.default_agent_id
  table_names      = var.table_names

  # Read from the assumed session rather than a variable, so the ARNs the IAM
  # policies are scoped to cannot be wrong.
  region     = data.aws_region.current.region
  account_id = data.aws_caller_identity.current.account_id

  vpc_id     = var.vpc_id
  subnet_ids = var.subnet_ids

  # ── Store ────────────────────────────────────────────────────────────────
  create_aurora             = var.create_aurora
  db_name                   = var.db_name
  db_engine_version         = var.db_engine_version
  db_parameter_group_family = var.db_parameter_group_family
  db_min_capacity           = var.db_min_capacity
  db_max_capacity           = var.db_max_capacity
  db_allowed_cidr_blocks    = var.db_allowed_cidr_blocks
  db_publicly_accessible    = var.db_publicly_accessible
  db_deletion_protection    = var.db_deletion_protection

  # ── Development store ────────────────────────────────────────────────────
  create_pgvector_ec2              = var.create_pgvector_ec2
  pgvector_ec2_subnet_id           = var.pgvector_ec2_subnet_id
  pgvector_ec2_instance_type       = var.pgvector_ec2_instance_type
  pgvector_ec2_allowed_cidr_blocks = var.pgvector_ec2_allowed_cidr_blocks
  pgvector_ec2_key_name            = var.pgvector_ec2_key_name
  use_pgvector_ec2_for_lambdas     = var.use_pgvector_ec2_for_lambdas
  lambda_layers                    = var.lambda_layers

  # ── API ──────────────────────────────────────────────────────────────────
  cors_allow_origins     = var.cors_allow_origins
  throttling_burst_limit = var.throttling_burst_limit
  throttling_rate_limit  = var.throttling_rate_limit
  log_retention_in_days  = var.log_retention_in_days

  # ── Feedback ─────────────────────────────────────────────────────────────
  feedback_threshold_days    = var.feedback_threshold_days
  feedback_threshold_minutes = var.feedback_threshold_minutes

  # ── Insight ──────────────────────────────────────────────────────────────
  embedding_model_id         = var.embedding_model_id
  labelling_model_id         = var.labelling_model_id
  briefing_model_id          = var.briefing_model_id
  cluster_distance_threshold = var.cluster_distance_threshold
  create_guardrail           = var.create_guardrail
  create_ecr_repository      = var.create_ecr_repository
  create_insight_agent       = var.create_insight_agent
  insight_agent_image_uri    = var.insight_agent_image_uri

  # ── Scheduling ───────────────────────────────────────────────────────────
  briefing_schedule_expression       = var.briefing_schedule_expression
  feedback_check_schedule_expression = var.feedback_check_schedule_expression
  embedding_schedule_expression      = var.embedding_schedule_expression
  schedules_enabled                  = var.schedules_enabled

  tags = var.tags
}

# The rendered migration, written next to the stack so it can be applied with
# psql or the Data API without going through a terraform output. It is
# idempotent, so re-applying it after a schema change is the normal path.
resource "local_file" "schema" {
  filename        = "${path.module}/.build/schema.sql"
  content         = module.adoption_tracker.schema_sql
  file_permission = "0644"
}
