variable "region" {
  type    = string
  default = "us-east-1"
}

variable "client" {
  type = string
}

variable "client_account_id" {
  type = string
}

variable "environment" {
  type = string
}

variable "name_prefix" {
  description = "Prefix for every resource name in this stack."
  type        = string
  default     = "lwa-vector"
}

# ── Network ──────────────────────────────────────────────────────────────────

variable "vpc_id" {
  description = "VPC to deploy into. Null uses the account's default VPC."
  type        = string
  default     = null
}

variable "subnet_ids" {
  description = "Subnets for the database and the function. Empty uses every subnet in the VPC."
  type        = list(string)
  default     = []
}

variable "endpoint_subnet_ids" {
  description = "Subnets for the Secrets Manager interface endpoint — one per AZ at most. Empty reuses subnet_ids."
  type        = list(string)
  default     = []
}

variable "api_gateway_vpc_endpoint_ids" {
  description = "Optional execute-api interface VPC endpoint IDs to associate with and restrict the private REST API."
  type        = list(string)
  default     = []
}

# ── Database ─────────────────────────────────────────────────────────────────

variable "db_engine_version" {
  description = "pgvector requires Postgres 15.2 or newer."
  type        = string
  default     = "16"
}

variable "db_parameter_group_family" {
  description = "Must track the major version in db_engine_version."
  type        = string
  default     = "postgres16"
}

variable "db_instance_class" {
  type    = string
  default = "db.t4g.micro"
}

variable "db_allocated_storage" {
  type    = number
  default = 20
}

variable "db_name" {
  type    = string
  default = "vectordb"
}

variable "db_master_username" {
  type    = string
  default = "postgres"
}

variable "use_managed_master_password" {
  description = <<-EOT
    true  — RDS generates and rotates the master password in Secrets Manager. Most
            secure, but the in-VPC function needs an interface endpoint to read it
            (see create_secretsmanager_vpc_endpoint), which costs ~$7/mo/AZ.
    false — Terraform generates the password and injects it into the function's
            environment. No extra cost, but the password lands in Terraform state.
            This is the demo default.
  EOT
  type        = bool
  default     = false
}

variable "create_secretsmanager_vpc_endpoint" {
  description = "Create the Secrets Manager interface endpoint. Only used when use_managed_master_password is true."
  type        = bool
  default     = true
}

variable "db_publicly_accessible" {
  description = <<-EOT
    Give the instance a public IP so clients outside the VPC (psql, TablePlus)
    can reach it. Requires the subnet group to hold public subnets, which the
    default VPC does. Access is still gated by db_allowed_cidr_blocks.
  EOT
  type        = bool
  default     = false
}

variable "db_allowed_cidr_blocks" {
  description = "CIDRs allowed to reach Postgres on 5432, e.g. [\"203.0.113.4/32\"]. Required for public access to be usable."
  type        = list(string)
  default     = []

  validation {
    condition     = !contains(var.db_allowed_cidr_blocks, "0.0.0.0/0")
    error_message = "Refusing 0.0.0.0/0: that exposes Postgres to the entire internet. List specific addresses instead."
  }
}

variable "db_storage_encrypted" {
  description = "Encrypt storage at rest. Encryption itself is free; the key is what costs."
  type        = bool
  default     = true
}

variable "db_create_kms_key" {
  description = <<-EOT
    Create a customer-managed KMS key for storage encryption (~$1/month) instead
    of relying on the AWS-managed `aws/rds` key. The AWS-managed key is created
    lazily on first use and is often absent in a fresh member account, which
    fails CreateDBInstance with KMSKeyNotAccessibleFault. Ignored when
    db_kms_key_id is set or db_storage_encrypted is false.
  EOT
  type        = bool
  default     = true
}

variable "db_kms_key_id" {
  description = "ARN of an existing KMS key to encrypt storage with. Overrides db_create_kms_key."
  type        = string
  default     = null
}

variable "db_kms_deletion_window_in_days" {
  description = "Waiting period before a destroyed key is deleted. Keys pending deletion are not billed."
  type        = number
  default     = 7
}

variable "db_backup_retention_period" {
  description = "Days of automated backups. 0 disables them for the cheapest demo."
  type        = number
  default     = 1
}

variable "db_skip_final_snapshot" {
  type    = bool
  default = true
}

variable "db_deletion_protection" {
  type    = bool
  default = false
}

# ── Lambda ───────────────────────────────────────────────────────────────────

variable "usage_handler" {
  type    = string
  default = "handlers.usage.lambda_handler"
}

variable "feedback_handler" {
  type    = string
  default = "handlers.feedback.lambda_handler"
}

variable "metrics_handler" {
  type    = string
  default = "handlers.metrics.lambda_handler"
}

variable "embedding_handler" {
  type    = string
  default = "handlers.embedding.lambda_handler"
}

variable "briefing_handler" {
  type    = string
  default = "handlers.briefing.lambda_handler"
}

variable "bootstrap_handler" {
  type    = string
  default = "handlers.bootstrap.lambda_handler"
}

variable "functions" {
  type = list(string)
  default = [ 
              "usage_function", 
              "feedback_function", 
              "metrics_function", 
              "embedding_function", 
              "briefing_function", 
              "bootstrap_function"
            ]
}



variable "runtime" {
  type    = string
  default = "python3.12"
}

variable "timeout" {
  type    = number
  default = 600
}

variable "memory_size" {
  type    = number
  default = 512
}

variable "layers" {
  description = "Layer ARNs. The handler needs a psycopg layer to talk to Postgres — see README.md."
  type        = list(string)
  default     = []
}

variable "environment_variables" {
  description = "Extra environment variables, merged over the database ones this stack sets."
  type        = map(string)
  default     = {}
}

# ── API Gateway ──────────────────────────────────────────────────────────────

variable "stage_name" {
  type    = string
  default = "$default"
}

variable "cors_allow_origins" {
  description = "Origins allowed by CORS. Null disables CORS entirely."
  type        = list(string)
  default     = null
}

variable "access_logs_enabled" {
  description = "Create API Gateway access logs. Enable after CloudWatch Logs permissions are available."
  type        = bool
  default     = false
}

variable "log_retention_in_days" {
  type    = number
  default = 14
}

variable "throttling_burst_limit" {
  type    = number
  default = 100
}

variable "throttling_rate_limit" {
  type    = number
  default = 50
}

variable "tags" {
  type    = map(string)
  default = {}
}
