# ─────────────────────────────────────────────────────────────────────────────
# AI Adoption & Feedback Tracker
#
# One HTTP API, four request handlers, one Aurora Serverless v2 Postgres
# cluster with pgvector, and a Bedrock agent that reads the aggregates back out
# through tools. Everything is prefixed with var.name_prefix and every table
# name is a variable, so a second apply with different values stands up a
# second working deployment rather than colliding with the first.
#
# The shape of the thing:
#
#   capture   SDK / CLI / raw HTTP
#   ingest    API Gateway HTTP API — API key in a header, throttled per stage
#   process   usage · feedback · metrics · embedding · briefing Lambdas
#   store     Aurora Serverless v2 + pgvector, reached over the RDS Data API
#   insight   AgentCore runtime running LangGraph, behind a Bedrock guardrail
#   surface   whatever reads GET /v1/insights
#
# The Lambdas are not VPC-attached, on purpose. The Data API is a regional
# HTTPS endpoint, so the functions need no ENI, no NAT gateway for Bedrock
# egress, and cannot exhaust max_connections the way a pool of concurrent
# invocations against a raw connection string does.
# ─────────────────────────────────────────────────────────────────────────────

data "aws_vpc" "default" {
  count   = var.vpc_id == null ? 1 : 0
  default = true
}

data "aws_subnets" "selected" {
  count = length(var.subnet_ids) == 0 ? 1 : 0

  filter {
    name   = "vpc-id"
    values = [local.vpc_id]
  }
}

locals {
  vpc_id     = var.vpc_id != null ? var.vpc_id : data.aws_vpc.default[0].id
  subnet_ids = length(var.subnet_ids) > 0 ? var.subnet_ids : data.aws_subnets.selected[0].ids

  name = var.name_prefix

  tags = merge(var.tags, {
    Stack       = local.name
    Environment = var.environment
    ManagedBy   = "terraform"
  })

  tables = {
    usage_events       = var.table_names.usage_events
    first_use          = var.table_names.first_use
    feedback_responses = var.table_names.feedback_responses
    barrier_themes     = var.table_names.barrier_themes
    insight_briefings  = var.table_names.insight_briefings
    agent_config       = var.table_names.agent_config
  }

  # The migration and the Lambdas take their table names from the same place,
  # so the two cannot drift. Exposed as an output for the migration runner.
  schema_sql = templatefile("${path.module}/sql/schema.sql.tftpl", merge(local.tables, {
    embedding_dimension = var.embedding_dimension
  }))

  # Which store the functions talk to. data_api is the real path; ec2 is the
  # development fallback, and switching is a variable rather than a rewrite.
  db_mode = var.use_pgvector_ec2_for_lambdas ? "ec2" : "data_api"

  cluster_arn   = var.create_aurora ? module.aurora[0].arn : null
  db_secret_arn = var.create_aurora ? module.aurora[0].master_user_secret_arn : null

  common_environment = merge(
    {
      DB_MODE             = local.db_mode
      DB_NAME             = var.db_name
      DEFAULT_AGENT_ID    = var.default_agent_id
      ENVIRONMENT         = var.environment
      LOG_LEVEL           = "INFO"
      EMBEDDING_DIMENSION = tostring(var.embedding_dimension)

      TABLE_USAGE_EVENTS       = local.tables.usage_events
      TABLE_FIRST_USE          = local.tables.first_use
      TABLE_FEEDBACK_RESPONSES = local.tables.feedback_responses
      TABLE_BARRIER_THEMES     = local.tables.barrier_themes
      TABLE_INSIGHT_BRIEFINGS  = local.tables.insight_briefings
      TABLE_AGENT_CONFIG       = local.tables.agent_config

      FEEDBACK_THRESHOLD_DAYS = tostring(var.feedback_threshold_days)
      DLQ_URL                 = module.dlq.url
    },
    var.feedback_threshold_minutes == null ? {} : {
      FEEDBACK_THRESHOLD_MINUTES = tostring(var.feedback_threshold_minutes)
    },
    var.create_aurora ? {
      DB_CLUSTER_ARN = module.aurora[0].arn
      DB_SECRET_ARN  = module.aurora[0].master_user_secret_arn
    } : {},
    var.create_pgvector_ec2 ? {
      DB_HOST     = module.pgvector_ec2[0].postgres_host
      DB_PORT     = tostring(module.pgvector_ec2[0].postgres_port)
      DB_USER     = var.db_master_username
      DB_PASSWORD = random_password.pgvector_ec2[0].result
    } : {},
    var.environment_variables,
  )
}

# Running the functions against the EC2 host needs a psycopg layer, because the
# driver is not in the Lambda runtime. Catching that here beats catching it as
# an ImportError in the first invocation after the switch.
resource "terraform_data" "preconditions" {
  lifecycle {
    precondition {
      condition     = !var.use_pgvector_ec2_for_lambdas || length(var.lambda_layers) > 0
      error_message = "use_pgvector_ec2_for_lambdas is set but lambda_layers is empty. The functions connect with psycopg in ec2 mode and it is not in the Lambda runtime — build a psycopg layer and pass its ARN."
    }

    precondition {
      condition     = !var.use_pgvector_ec2_for_lambdas || var.create_pgvector_ec2
      error_message = "use_pgvector_ec2_for_lambdas is set but create_pgvector_ec2 is false, so there is no host to point at."
    }

    precondition {
      condition     = var.create_aurora || var.create_pgvector_ec2
      error_message = "Both create_aurora and create_pgvector_ec2 are false, which leaves the stack with nowhere to store anything."
    }

    precondition {
      condition     = !var.create_insight_agent || var.insight_agent_image_uri != null || var.create_ecr_repository
      error_message = "create_insight_agent needs an image: either set insight_agent_image_uri or leave create_ecr_repository true and push to the repository this module creates."
    }
  }
}
