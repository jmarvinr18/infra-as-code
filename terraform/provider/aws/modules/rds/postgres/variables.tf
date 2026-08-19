variable "identifier" {
  description = "DB instance identifier; also prefixes the subnet group, parameter group and security group."
  type        = string
}

variable "vpc_id" {
  type = string
}

variable "subnet_ids" {
  description = "Subnets for the DB subnet group. RDS requires at least two, in different AZs."
  type        = list(string)

  validation {
    condition     = length(var.subnet_ids) >= 2
    error_message = "RDS requires a subnet group spanning at least two availability zones."
  }
}

# ── Engine / sizing ──────────────────────────────────────────────────────────

variable "engine_version" {
  description = "Postgres version. pgvector requires 15.2 or newer. A major-only value (\"16\") tracks the latest minor."
  type        = string
  default     = "16"
}

variable "instance_class" {
  description = "db.t4g.micro is the cheapest class that supports Postgres and is enough for a demo."
  type        = string
  default     = "db.t4g.micro"
}

variable "allocated_storage" {
  description = "GiB. 20 is the minimum for gp3."
  type        = number
  default     = 20
}

variable "max_allocated_storage" {
  description = "Upper bound for storage autoscaling. 0 disables autoscaling."
  type        = number
  default     = 0
}

variable "storage_type" {
  type    = string
  default = "gp3"
}

variable "storage_encrypted" {
  type    = bool
  default = true
}

variable "kms_key_id" {
  description = "KMS key for storage encryption. Null uses the AWS-managed aws/rds key (no extra cost)."
  type        = string
  default     = null
}

# ── Credentials / database ───────────────────────────────────────────────────

variable "db_name" {
  description = "Name of the initial database created on the instance."
  type        = string
  default     = "vectordb"
}

variable "master_username" {
  type    = string
  default = "postgres"
}

variable "manage_master_user_password" {
  description = "Let RDS generate and rotate the master password in Secrets Manager. Keeps the password out of Terraform state."
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

# ── Networking ───────────────────────────────────────────────────────────────

variable "create_security_group" {
  type    = bool
  default = true
}

variable "allowed_security_group_ids" {
  description = "Security groups allowed to reach the instance on var.port (e.g. the Lambda's SG). Rules are keyed by list position, so reordering recreates them."
  type        = list(string)
  default     = []
}

variable "allowed_cidr_blocks" {
  description = "CIDRs allowed to reach the instance on var.port."
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

variable "multi_az" {
  description = "Off for a demo — Multi-AZ roughly doubles the instance cost."
  type        = bool
  default     = false
}

variable "availability_zone" {
  description = "Pin the instance to one AZ. Ignored when multi_az is true."
  type        = string
  default     = null
}

# ── Parameter group ──────────────────────────────────────────────────────────

variable "create_parameter_group" {
  type    = bool
  default = true
}

variable "parameter_group_family" {
  description = "Must match the major version of engine_version (e.g. postgres16)."
  type        = string
  default     = "postgres16"
}

variable "parameter_group_name" {
  description = "Existing parameter group to use when create_parameter_group is false."
  type        = string
  default     = null
}

variable "parameters" {
  type = list(object({
    name         = string
    value        = string
    apply_method = optional(string, "immediate")
  }))
  default = []
}

# ── Backup / lifecycle ───────────────────────────────────────────────────────

variable "backup_retention_period" {
  description = "Days of automated backups. 0 disables them, which is the cheapest option for a demo."
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
  description = "Defaults to \"<identifier>-final\" when skip_final_snapshot is false."
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

variable "allow_major_version_upgrade" {
  type    = bool
  default = false
}

variable "apply_immediately" {
  type    = bool
  default = false
}

# ── Observability ────────────────────────────────────────────────────────────

variable "performance_insights_enabled" {
  description = "Off by default — not available on every t-class instance and billed beyond the 7-day tier."
  type        = bool
  default     = false
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
