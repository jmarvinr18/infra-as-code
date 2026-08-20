variable "cluster_identifier" {
  description = "Cluster identifier; also prefixes the subnet group, parameter group and security group."
  type        = string
}

variable "vpc_id" {
  type = string
}

variable "subnet_ids" {
  description = "Subnets for the DB subnet group. Aurora requires at least two, in different AZs."
  type        = list(string)

  validation {
    condition     = length(var.subnet_ids) >= 2
    error_message = "Aurora requires a subnet group spanning at least two availability zones."
  }
}

# ── Engine / capacity ────────────────────────────────────────────────────────

variable "engine_version" {
  description = "Aurora PostgreSQL version. pgvector needs 15.3+; scale-to-zero needs 15.7+ or 16.3+."
  type        = string
  default     = "16.6"
}

variable "instance_count" {
  description = "Serverless v2 writers/readers. One writer is enough for a demo."
  type        = number
  default     = 1
}

variable "min_capacity" {
  description = "Minimum Aurora Capacity Units. 0 lets the cluster pause when idle — the only setting that keeps an unused demo near zero cost."
  type        = number
  default     = 0
}

variable "max_capacity" {
  description = "Maximum Aurora Capacity Units."
  type        = number
  default     = 2
}

variable "seconds_until_auto_pause" {
  description = "Idle seconds before pausing. Only applies when min_capacity is 0. 300 is the AWS minimum."
  type        = number
  default     = 300

  validation {
    condition     = var.seconds_until_auto_pause >= 300 && var.seconds_until_auto_pause <= 86400
    error_message = "seconds_until_auto_pause must be between 300 and 86400."
  }
}

# ── Credentials / database ───────────────────────────────────────────────────

variable "db_name" {
  type    = string
  default = "adoption"
}

variable "master_username" {
  type    = string
  default = "postgres"
}

variable "manage_master_user_password" {
  description = "Let RDS generate and rotate the master password in Secrets Manager. Keeps the password out of state, and gives the Data API the secret it authenticates with."
  type        = bool
  default     = true
}

variable "master_password" {
  description = "Explicit master password. Only used when manage_master_user_password is false; it is stored in state."
  type        = string
  default     = null
  sensitive   = true
}

variable "port" {
  type    = number
  default = 5432
}

# ── Data API ─────────────────────────────────────────────────────────────────

variable "enable_http_endpoint" {
  description = "Enable the RDS Data API. Callers then reach the cluster over regional HTTPS, which keeps Lambdas out of the VPC — no NAT gateway, no VPC cold start, no connection-pool exhaustion."
  type        = bool
  default     = true
}

variable "data_api_secret_arn" {
  description = "Secret the Data API authenticates with, when manage_master_user_password is false. Only read by the module's precondition."
  type        = string
  default     = null
}

# ── Networking ───────────────────────────────────────────────────────────────

variable "create_security_group" {
  type    = bool
  default = true
}

variable "allowed_security_group_ids" {
  description = "Security groups allowed to reach the cluster on var.port. Rules are keyed by list position, so reordering recreates them. Data API callers need nothing here."
  type        = list(string)
  default     = []
}

variable "allowed_cidr_blocks" {
  description = "CIDRs allowed to reach the cluster on var.port."
  type        = list(string)
  default     = []
}

variable "vpc_security_group_ids" {
  description = "Pre-existing security groups to attach in addition to the one this module creates."
  type        = list(string)
  default     = []
}

variable "publicly_accessible" {
  type    = bool
  default = false
}

# ── Storage / encryption ─────────────────────────────────────────────────────

variable "storage_encrypted" {
  type    = bool
  default = true
}

variable "kms_key_id" {
  description = "KMS key for storage encryption. Null uses the AWS-managed aws/rds key."
  type        = string
  default     = null
}

# ── Parameter group ──────────────────────────────────────────────────────────

variable "create_parameter_group" {
  type    = bool
  default = true
}

variable "parameter_group_family" {
  description = "Must match the major version of engine_version (e.g. aurora-postgresql16)."
  type        = string
  default     = "aurora-postgresql16"
}

variable "parameter_group_name" {
  description = "Existing cluster parameter group to use when create_parameter_group is false."
  type        = string
  default     = null
}

variable "cluster_parameters" {
  type = list(object({
    name         = string
    value        = string
    apply_method = optional(string, "immediate")
  }))
  default = []
}

# ── Backup / lifecycle ───────────────────────────────────────────────────────

variable "backup_retention_period" {
  description = "Days of automated backups. 1 is the Aurora minimum."
  type        = number
  default     = 1
}

variable "backup_window" {
  type    = string
  default = null
}

variable "maintenance_window" {
  type    = string
  default = null
}

variable "skip_final_snapshot" {
  type    = bool
  default = true
}

variable "final_snapshot_identifier" {
  description = "Defaults to \"<cluster_identifier>-final\" when skip_final_snapshot is false."
  type        = string
  default     = null
}

variable "deletion_protection" {
  type    = bool
  default = false
}

variable "auto_minor_version_upgrade" {
  type    = bool
  default = true
}

variable "apply_immediately" {
  type    = bool
  default = false
}

# ── Observability ────────────────────────────────────────────────────────────

variable "performance_insights_enabled" {
  type    = bool
  default = false
}

variable "monitoring_interval" {
  description = "Enhanced Monitoring granularity in seconds. 0 disables it (and its CloudWatch Logs charge)."
  type        = number
  default     = 0
}

variable "enabled_cloudwatch_logs_exports" {
  description = "Log types to ship to CloudWatch Logs, e.g. [\"postgresql\"]. Empty keeps the demo free of log ingestion cost."
  type        = list(string)
  default     = []
}

variable "tags" {
  type    = map(string)
  default = {}
}
