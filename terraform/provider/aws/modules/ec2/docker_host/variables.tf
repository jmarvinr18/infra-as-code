variable "name" {
  description = "Name for the instance and its dependent resources."
  type        = string
}

variable "vpc_id" {
  type = string
}

variable "subnet_id" {
  description = "Public subnet. A SQL client and a non-VPC Lambda both reach this host over the internet."
  type        = string
}

# ── Instance ─────────────────────────────────────────────────────────────────

variable "ami_id" {
  description = "AMI to launch. Null resolves the latest Amazon Linux 2023 image."
  type        = string
  default     = null
}

variable "architecture" {
  description = "Used to pick the AL2023 AMI. arm64 pairs with t4g instance types and is the cheaper option."
  type        = string
  default     = "arm64"

  validation {
    condition     = contains(["arm64", "x86_64"], var.architecture)
    error_message = "architecture must be arm64 or x86_64."
  }
}

variable "instance_type" {
  description = "t4g.small gives Postgres 2 GiB, which is enough for development data. Must match var.architecture."
  type        = string
  default     = "t4g.small"
}

variable "key_name" {
  description = "EC2 key pair for SSH. Null leaves SSH closed and uses Session Manager instead."
  type        = string
  default     = null
}

variable "root_volume_size" {
  type    = number
  default = 30
}

variable "root_volume_type" {
  type    = string
  default = "gp3"
}

variable "associate_public_ip_address" {
  type    = bool
  default = true
}

variable "create_eip" {
  description = "Attach an Elastic IP so the address survives a stop/start — worth it for a host whose connection string is saved in everyone's SQL client."
  type        = bool
  default     = true
}

variable "detailed_monitoring" {
  type    = bool
  default = false
}

variable "user_data_replace_on_change" {
  description = "Replace the instance when the bootstrap script changes. True is honest — user_data only runs on first boot, so an edited script otherwise silently does nothing."
  type        = bool
  default     = true
}

# ── Access ───────────────────────────────────────────────────────────────────

variable "create_security_group" {
  type    = bool
  default = true
}

variable "allowed_postgres_cidr_blocks" {
  description = <<-EOT
    CIDRs allowed to reach Postgres. Keep this to known addresses — office or
    home IPs as /32, plus the NAT address of anything else that connects.

    A Lambda that is not VPC-attached has no fixed source address, so there is
    no narrow CIDR that covers it. If a function must reach this host, either
    accept 0.0.0.0/0 for development data behind a long generated password, or
    attach the function to this VPC and use allowed_postgres_security_group_ids
    instead. Do not carry the open setting into anything holding real data.
  EOT
  type        = list(string)
  default     = []
}

variable "allowed_postgres_security_group_ids" {
  description = "Security groups allowed to reach Postgres, for VPC-attached callers. Rules are keyed by list position, so reordering recreates them."
  type        = list(string)
  default     = []
}

variable "allowed_ssh_cidr_blocks" {
  description = "CIDRs allowed on port 22. Only used when key_name is set."
  type        = list(string)
  default     = []
}

variable "vpc_security_group_ids" {
  description = "Pre-existing security groups to attach in addition to the one this module creates."
  type        = list(string)
  default     = []
}

variable "create_instance_profile" {
  description = "Create a role with AmazonSSMManagedInstanceCore so the host is reachable through Session Manager."
  type        = bool
  default     = true
}

variable "iam_instance_profile" {
  description = "Existing instance profile name, used when create_instance_profile is false."
  type        = string
  default     = null
}

variable "additional_policy_arns" {
  description = "Extra managed policies for the instance role."
  type        = list(string)
  default     = []
}

# ── Postgres container ───────────────────────────────────────────────────────

variable "postgres_image" {
  description = "Upstream Postgres with pgvector already compiled in — nothing is built on the instance."
  type        = string
  default     = "pgvector/pgvector:pg16"
}

variable "container_name" {
  type    = string
  default = "pgvector"
}

variable "postgres_db" {
  type    = string
  default = "adoption"
}

variable "postgres_user" {
  type    = string
  default = "postgres"
}

variable "postgres_password" {
  description = "Master password. Written to the instance and held in Terraform state — generate it with random_password rather than typing one in."
  type        = string
  sensitive   = true
}

variable "postgres_port" {
  type    = number
  default = 5432
}

variable "max_connections" {
  type    = number
  default = 200
}

variable "shared_buffers" {
  description = "Roughly a quarter of instance memory."
  type        = string
  default     = "512MB"
}

variable "shm_size" {
  description = "Docker's default 64MB is too small for Postgres parallel query workers."
  type        = string
  default     = "256mb"
}

variable "extra_initdb_sql" {
  description = "SQL applied once, on first boot of an empty data volume — the schema migration goes here."
  type        = string
  default     = null
}

variable "compose_version" {
  type    = string
  default = "2.32.4"
}

variable "compose_dir" {
  type    = string
  default = "/opt/pgvector"
}

variable "extra_user_data" {
  description = "Shell appended to the end of the bootstrap script."
  type        = string
  default     = ""
}

variable "tags" {
  type    = map(string)
  default = {}
}
