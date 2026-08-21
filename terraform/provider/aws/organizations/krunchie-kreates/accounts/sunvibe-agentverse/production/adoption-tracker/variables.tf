variable "region" {
  type    = string
  default = "ap-southeast-1"
}

variable "client" {
  type = string
}

variable "client_account_id" {
  description = "Member account this stack is applied into. Used to assume OrganizationAccountAccessRole."
  type        = string
}

variable "environment" {
  type    = string
  default = "production"
}

variable "name_prefix" {
  description = "Prefix for every resource. Change it and a second apply stands up a parallel deployment rather than colliding with this one."
  type        = string
  default     = "adoption-tracker"
}

variable "default_agent_id" {
  type    = string
  default = "default"
}

variable "table_names" {
  description = "Physical table names. Override to run two deployments against one database."
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

# ── Network ──────────────────────────────────────────────────────────────────

variable "vpc_id" {
  description = "VPC for the database. Null uses the account's default VPC."
  type        = string
  default     = null
}

variable "subnet_ids" {
  description = "Subnets for the DB subnet group. Empty uses every subnet in the VPC."
  type        = list(string)
  default     = []
}

# ── Store ────────────────────────────────────────────────────────────────────

variable "create_aurora" {
  type    = bool
  default = true
}

variable "db_name" {
  type    = string
  default = "adoption"
}

variable "db_engine_version" {
  type    = string
  default = "16.6"
}

variable "db_parameter_group_family" {
  type    = string
  default = "aurora-postgresql16"
}

variable "db_min_capacity" {
  description = "0 pauses the cluster when idle. If the account refuses it, raise this and say what the floor costs rather than repeating a scale-to-zero claim."
  type        = number
  default     = 0
}

variable "db_max_capacity" {
  type    = number
  default = 2
}

variable "db_allowed_cidr_blocks" {
  description = "CIDRs allowed to reach the cluster directly on 5432. Data API callers need nothing here."
  type        = list(string)
  default     = []
}

variable "db_publicly_accessible" {
  type    = bool
  default = false
}

variable "db_deletion_protection" {
  type    = bool
  default = false
}

# ── Development store ────────────────────────────────────────────────────────

variable "create_pgvector_ec2" {
  type    = bool
  default = true
}

variable "pgvector_ec2_subnet_id" {
  type    = string
  default = null
}

variable "pgvector_ec2_instance_type" {
  type    = string
  default = "t4g.small"
}

variable "pgvector_ec2_allowed_cidr_blocks" {
  description = "Addresses allowed to reach the Docker host on 5432 — the developer IPs that connect with TablePlus or DBeaver."
  type        = list(string)
  default     = []
}

variable "pgvector_ec2_key_name" {
  type    = string
  default = null
}

variable "use_pgvector_ec2_for_lambdas" {
  type    = bool
  default = false
}

variable "lambda_layers" {
  description = "Layer ARNs for every function. A psycopg layer is required when use_pgvector_ec2_for_lambdas is true."
  type        = list(string)
  default     = []
}

# ── API ──────────────────────────────────────────────────────────────────────

variable "cors_allow_origins" {
  type    = list(string)
  default = null
}

variable "throttling_burst_limit" {
  type    = number
  default = 100
}

variable "throttling_rate_limit" {
  type    = number
  default = 50
}

variable "log_retention_in_days" {
  type    = number
  default = 14
}

# ── Feedback ─────────────────────────────────────────────────────────────────

variable "feedback_threshold_days" {
  type    = number
  default = 14
}

variable "feedback_threshold_minutes" {
  description = "Per-agent demo threshold. Null leaves every agent on threshold_days."
  type        = number
  default     = null
}

# ── Insight ──────────────────────────────────────────────────────────────────

variable "embedding_model_id" {
  type    = string
  default = "amazon.titan-embed-text-v2:0"
}

variable "labelling_model_id" {
  type    = string
  default = "anthropic.claude-3-5-haiku-20241022-v1:0"
}

variable "briefing_model_id" {
  type    = string
  default = "anthropic.claude-3-5-sonnet-20241022-v2:0"
}

variable "cluster_distance_threshold" {
  type    = number
  default = 0.35
}

variable "create_guardrail" {
  type    = bool
  default = true
}

variable "create_ecr_repository" {
  type    = bool
  default = true
}

variable "create_insight_agent" {
  description = "Leave false until the container image is pushed — the runtime cannot start from an empty repository."
  type        = bool
  default     = false
}

variable "insight_agent_image_uri" {
  type    = string
  default = null
}

# ── Scheduling ───────────────────────────────────────────────────────────────

variable "briefing_schedule_expression" {
  type    = string
  default = "cron(0 18 * * ? *)"
}

variable "feedback_check_schedule_expression" {
  type    = string
  default = "cron(0 1 * * ? *)"
}

variable "embedding_schedule_expression" {
  type    = string
  default = "rate(1 hour)"
}

variable "schedules_enabled" {
  type    = bool
  default = true
}

variable "tags" {
  type    = map(string)
  default = {}
}
