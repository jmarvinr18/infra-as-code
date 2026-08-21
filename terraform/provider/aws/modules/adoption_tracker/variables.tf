# ─────────────────────────────────────────────────────────────────────────────
# Identity
# ─────────────────────────────────────────────────────────────────────────────

variable "name_prefix" {
  description = "Prefix for every resource this module creates. Two deployments in one account must not share it."
  type        = string
  default     = "adoption-tracker"

  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{2,24}$", var.name_prefix))
    error_message = "name_prefix must be 3-25 lowercase alphanumeric characters or hyphens, starting with a letter."
  }
}

variable "environment" {
  description = "Deployment environment. Part of resource names, and returned in the health response."
  type        = string
  default     = "production"
}

variable "default_agent_id" {
  description = "Agent recorded when a caller omits agent_id. Every table is keyed by agent_id, so two agents coexist in one deployment; this is only the fallback."
  type        = string
  default     = "default"
}

variable "region" {
  description = "Region the stack is deployed into. Used to build ARNs and the Bedrock endpoint."
  type        = string
}

variable "account_id" {
  description = "Account the stack is deployed into. Used to scope IAM resources without a wildcard."
  type        = string
}

# ─────────────────────────────────────────────────────────────────────────────
# Schema
#
# Table names are variables so a second apply into the same database — or a
# team vendoring this module into their own repo — does not collide. The names
# reach both the migration and the Lambdas from here, so the two can never
# drift apart.
# ─────────────────────────────────────────────────────────────────────────────

variable "table_names" {
  description = "Physical table names. Keys are fixed; values are yours."
  type = object({
    usage_events       = optional(string, "usage_events")
    first_use          = optional(string, "first_use")
    feedback_responses = optional(string, "feedback_responses")
    barrier_themes     = optional(string, "barrier_themes")
    insight_briefings  = optional(string, "insight_briefings")
    agent_config       = optional(string, "agent_config")
  })
  default = {}
}

variable "embedding_dimension" {
  description = "Vector width. 1024 is the Titan Text Embeddings v2 default and must match the model's output_embedding_length."
  type        = number
  default     = 1024
}

# ─────────────────────────────────────────────────────────────────────────────
# Network
#
# Only the database needs a VPC. The Lambdas deliberately stay outside one:
# reaching Postgres through the Data API means no ENI cold start, no
# connection-pool exhaustion, and no NAT gateway standing charge for Bedrock
# egress. Defaults fall back to the account's default VPC so the stack applies
# without a prior network build.
# ─────────────────────────────────────────────────────────────────────────────

variable "vpc_id" {
  description = "VPC for the database. Null uses the account's default VPC."
  type        = string
  default     = null
}

variable "subnet_ids" {
  description = "Subnets for the DB subnet group; at least two AZs. Empty uses every subnet in the VPC."
  type        = list(string)
  default     = []
}

# ─────────────────────────────────────────────────────────────────────────────
# Store — Aurora Serverless v2
# ─────────────────────────────────────────────────────────────────────────────

variable "create_aurora" {
  description = "Create the Aurora cluster. Turn off to run entirely against the EC2 pgvector host during development."
  type        = bool
  default     = true
}

variable "db_name" {
  type    = string
  default = "adoption"
}

variable "db_master_username" {
  type    = string
  default = "postgres"
}

variable "db_engine_version" {
  description = "Aurora PostgreSQL version. pgvector needs 15.3+; scale-to-zero needs 15.7+ or 16.3+. Confirm the Data API is available for whatever you pick — that is a day-one check, not a day-five discovery."
  type        = string
  default     = "16.6"
}

variable "db_parameter_group_family" {
  type    = string
  default = "aurora-postgresql16"
}

variable "db_min_capacity" {
  description = "Minimum ACUs. 0 pauses the cluster when idle and is the difference between a few dollars for the week and a standing hourly charge. Some accounts do not permit it — check, and if it is refused say what the floor actually costs rather than repeating a scale-to-zero claim."
  type        = number
  default     = 0
}

variable "db_max_capacity" {
  type    = number
  default = 2
}

variable "db_seconds_until_auto_pause" {
  description = "Idle seconds before pausing. 300 is the AWS minimum."
  type        = number
  default     = 300
}

variable "db_backup_retention_period" {
  type    = number
  default = 1
}

variable "db_deletion_protection" {
  type    = bool
  default = false
}

variable "db_skip_final_snapshot" {
  type    = bool
  default = true
}

variable "db_allowed_cidr_blocks" {
  description = "CIDRs allowed to reach the cluster directly on 5432, for psql or a migration runner. Data API callers need nothing here."
  type        = list(string)
  default     = []
}

variable "db_publicly_accessible" {
  type    = bool
  default = false
}

# ─────────────────────────────────────────────────────────────────────────────
# Development store — EC2 + Docker pgvector
#
# The fallback for the week: same engine, same extension, ordinary connection
# string. It exists so a Data API quota or an unavailable engine version cannot
# stall the Lambda work. Point the functions at it, keep building, switch back.
# ─────────────────────────────────────────────────────────────────────────────

variable "create_pgvector_ec2" {
  description = "Create the EC2 Docker host running Postgres + pgvector."
  type        = bool
  default     = false
}

variable "pgvector_ec2_subnet_id" {
  description = "Public subnet for the Docker host. Null picks the first entry of the resolved subnet list."
  type        = string
  default     = null
}

variable "pgvector_ec2_instance_type" {
  type    = string
  default = "t4g.small"
}

variable "pgvector_ec2_architecture" {
  type    = string
  default = "arm64"
}

variable "pgvector_ec2_allowed_cidr_blocks" {
  description = <<-EOT
    CIDRs allowed to reach the Docker host on 5432 — the developer addresses
    that connect with TablePlus, DBeaver or psql.

    A Lambda outside a VPC has no fixed source address, so no narrow CIDR
    covers it. If the functions must reach this host you are choosing between
    0.0.0.0/0 for development data behind a generated password, and attaching
    the functions to the VPC. Make that choice here, in the open.
  EOT
  type        = list(string)
  default     = []
}

variable "pgvector_ec2_key_name" {
  description = "EC2 key pair for SSH. Null leaves port 22 closed and uses Session Manager."
  type        = string
  default     = null
}

variable "pgvector_ec2_root_volume_size" {
  type    = number
  default = 30
}

variable "use_pgvector_ec2_for_lambdas" {
  description = "Point the Lambdas at the EC2 host instead of the Data API. The development escape hatch — the functions read DB_MODE and switch connection strategy."
  type        = bool
  default     = false
}

# ─────────────────────────────────────────────────────────────────────────────
# Ingest — API Gateway and Lambda
# ─────────────────────────────────────────────────────────────────────────────

variable "stage_name" {
  type    = string
  default = "$default"
}

variable "cors_allow_origins" {
  description = "Origins allowed to call the API from a browser. Null disables CORS."
  type        = list(string)
  default     = null
}

variable "throttling_burst_limit" {
  type    = number
  default = 100
}

variable "throttling_rate_limit" {
  type    = number
  default = 50
}

variable "regenerate_throttling_burst_limit" {
  description = "Separate, tighter limit for the on-demand regenerate route — one agent invocation per request is the most expensive thing this API does."
  type        = number
  default     = 2
}

variable "regenerate_throttling_rate_limit" {
  type    = number
  default = 1
}

variable "lambda_runtime" {
  type    = string
  default = "python3.12"
}

variable "lambda_architecture" {
  description = "arm64 is cheaper per millisecond and is what the runtime defaults to on Graviton."
  type        = string
  default     = "arm64"
}

variable "lambda_timeout" {
  type    = number
  default = 30
}

variable "lambda_memory_size" {
  type    = number
  default = 512

  validation {
    condition     = var.lambda_memory_size >= 256
    error_message = "The Data API client needs headroom; 256 MB is the practical floor."
  }
}

variable "embedding_lambda_timeout" {
  description = "The embedding job walks every unembedded row, so it needs more than a request handler."
  type        = number
  default     = 300
}

variable "log_retention_in_days" {
  description = "Applies to the Lambda log groups and the API access log. Never-expiring logs are a slow, invisible bill."
  type        = number
  default     = 14
}

variable "environment_variables" {
  description = "Extra environment variables merged into every function."
  type        = map(string)
  default     = {}
}

# ─────────────────────────────────────────────────────────────────────────────
# Feedback thresholds
# ─────────────────────────────────────────────────────────────────────────────

variable "feedback_threshold_days" {
  description = "Days after first use before a survey becomes due."
  type        = number
  default     = 14
}

variable "feedback_threshold_minutes" {
  description = <<-EOT
    Minutes after first use before a survey becomes due, when an agent's config
    sets it. This is not a shortcut left in by accident: the demo has to show a
    survey firing, and nobody can wait fourteen days on stage. It is per-agent
    configuration in agent_config, it is null unless someone sets it, and when
    it is set it takes precedence over threshold_days.
  EOT
  type        = number
  default     = null
}

# ─────────────────────────────────────────────────────────────────────────────
# Insight — Bedrock
# ─────────────────────────────────────────────────────────────────────────────

variable "embedding_model_id" {
  description = "Titan Text Embeddings v2. Chosen over a HuggingFace embedding so the container never has to carry sentence-transformers and CUDA."
  type        = string
  default     = "amazon.titan-embed-text-v2:0"
}

variable "labelling_model_id" {
  description = "Model that names the barrier clusters. One batched call per run, never one per response."
  type        = string
  default     = "anthropic.claude-3-5-haiku-20241022-v1:0"
}

variable "briefing_model_id" {
  description = "Model behind the briefing agent's ChatBedrockConverse."
  type        = string
  default     = "anthropic.claude-3-5-sonnet-20241022-v2:0"
}

variable "cluster_distance_threshold" {
  description = "Maximum cosine distance for a barrier to join an existing theme. Lower is stricter. Tune this against seed data before blaming the model for merging unrelated barriers."
  type        = number
  default     = 0.35
}

variable "create_guardrail" {
  description = "Create the Bedrock guardrail. It is the outer net around the briefing — the citation check in the graph is the real control."
  type        = bool
  default     = true
}

variable "guardrail_grounding_threshold" {
  type    = number
  default = 0.75
}

variable "guardrail_relevance_threshold" {
  type    = number
  default = 0.5
}

variable "create_ecr_repository" {
  description = "Create the ECR repository for the AgentCore container image."
  type        = bool
  default     = true
}

variable "create_insight_agent" {
  description = <<-EOT
    Create the AgentCore runtime. Leave false until the container image is
    actually pushed — the runtime resource fails on a repository with no image,
    and that is a bad thing to discover on day six. Build the image early, push
    it, then flip this on.
  EOT
  type        = bool
  default     = false
}

variable "insight_agent_image_uri" {
  description = "Image the AgentCore runtime runs. Null uses the module's own ECR repository at :latest."
  type        = string
  default     = null
}

variable "insight_agent_network_mode" {
  type    = string
  default = "PUBLIC"
}

# ─────────────────────────────────────────────────────────────────────────────
# Scheduling
# ─────────────────────────────────────────────────────────────────────────────

variable "briefing_schedule_expression" {
  description = "Nightly regeneration. Briefings are cached so dashboard traffic does not turn into agent invocations."
  type        = string
  default     = "cron(0 18 * * ? *)"
}

variable "feedback_check_schedule_expression" {
  description = "Daily sweep for users who have crossed their feedback threshold."
  type        = string
  default     = "cron(0 1 * * ? *)"
}

variable "embedding_schedule_expression" {
  description = "How often unembedded barriers are picked up and clustered."
  type        = string
  default     = "rate(1 hour)"
}

variable "schedules_enabled" {
  description = "Disable to stop every scheduled rule at once without destroying them."
  type        = bool
  default     = true
}

variable "tags" {
  type    = map(string)
  default = {}
}

variable "lambda_layers" {
  description = <<-EOT
    Layer ARNs attached to every function.

    Empty is correct for the Data API path: boto3 is already in the runtime and
    nothing else is imported. Running the functions against the EC2 pgvector
    host needs a psycopg layer here — the driver is not in the Lambda runtime,
    which is why use_pgvector_ec2_for_lambdas asserts this is set.
  EOT
  type        = list(string)
  default     = []
}
