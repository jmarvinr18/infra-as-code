locals {
  security_group_ids = concat(
    var.create_security_group ? [aws_security_group.this[0].id] : [],
    var.vpc_security_group_ids,
  )
}

resource "aws_db_subnet_group" "this" {
  name       = "${var.identifier}-subnets"
  subnet_ids = var.subnet_ids

  tags = var.tags
}

# ─────────────────────────────────────────────────────────────────────────────
# Security group — no egress rules; a Postgres instance only ever answers.
# Ingress is granted to caller security groups (preferred) and/or raw CIDRs.
# ─────────────────────────────────────────────────────────────────────────────

resource "aws_security_group" "this" {
  count = var.create_security_group ? 1 : 0

  name        = "${var.identifier}-rds"
  description = "Postgres access for ${var.identifier}"
  vpc_id      = var.vpc_id

  tags = merge(var.tags, { Name = "${var.identifier}-rds" })
}

# Keyed by list position, not by the id itself: a caller's security group is
# almost always created in the same apply, so its id is unknown at plan time and
# cannot be used as a for_each key. Reordering the list recreates the rules.
resource "aws_vpc_security_group_ingress_rule" "from_security_group" {
  for_each = var.create_security_group ? { for i, id in var.allowed_security_group_ids : tostring(i) => id } : {}

  security_group_id            = aws_security_group.this[0].id
  description                  = "Postgres from source security group ${each.key}"
  referenced_security_group_id = each.value
  ip_protocol                  = "tcp"
  from_port                    = var.port
  to_port                      = var.port
}

resource "aws_vpc_security_group_ingress_rule" "from_cidr" {
  for_each = var.create_security_group ? { for i, cidr in var.allowed_cidr_blocks : tostring(i) => cidr } : {}

  security_group_id = aws_security_group.this[0].id
  description       = "Postgres from ${each.value}"
  cidr_ipv4         = each.value
  ip_protocol       = "tcp"
  from_port         = var.port
  to_port           = var.port
}

# ─────────────────────────────────────────────────────────────────────────────
# Parameter group.
#
# pgvector needs no preloaded library — it ships with RDS Postgres 15.2+ and is
# enabled per-database with `CREATE EXTENSION vector;` after the instance is up.
# ─────────────────────────────────────────────────────────────────────────────

resource "aws_db_parameter_group" "this" {
  count = var.create_parameter_group ? 1 : 0

  name        = "${var.identifier}pg"
  family      = var.parameter_group_family
  description = "Parameter group for ${var.identifier}"

  dynamic "parameter" {
    for_each = var.parameters
    content {
      name         = parameter.value.name
      value        = parameter.value.value
      apply_method = parameter.value.apply_method
    }
  }

  lifecycle {
    create_before_destroy = true
  }

  tags = var.tags
}

resource "aws_db_instance" "this" {
  identifier     = var.identifier
  engine         = "postgres"
  engine_version = var.engine_version
  instance_class = var.instance_class

  allocated_storage     = var.allocated_storage
  max_allocated_storage = var.max_allocated_storage
  storage_type          = var.storage_type
  storage_encrypted     = var.storage_encrypted
  kms_key_id            = var.kms_key_id

  db_name  = var.db_name
  username = var.master_username
  port     = var.port

  # Either AWS manages the master password in Secrets Manager (default, keeps
  # the secret out of state) or an explicit password is supplied.
  manage_master_user_password = var.manage_master_user_password ? true : null
  password                    = var.manage_master_user_password ? null : var.master_password

  db_subnet_group_name   = aws_db_subnet_group.this.name
  vpc_security_group_ids = local.security_group_ids
  publicly_accessible    = var.publicly_accessible
  multi_az               = var.multi_az
  availability_zone      = var.multi_az ? null : var.availability_zone

  parameter_group_name = var.create_parameter_group ? aws_db_parameter_group.this[0].name : var.parameter_group_name

  backup_retention_period = var.backup_retention_period
  backup_window           = var.backup_window
  maintenance_window      = var.maintenance_window
  copy_tags_to_snapshot   = true

  skip_final_snapshot       = var.skip_final_snapshot
  final_snapshot_identifier = var.skip_final_snapshot ? null : coalesce(var.final_snapshot_identifier, "${var.identifier}-final")
  deletion_protection       = var.deletion_protection

  auto_minor_version_upgrade   = var.auto_minor_version_upgrade
  allow_major_version_upgrade  = var.allow_major_version_upgrade
  apply_immediately            = var.apply_immediately
  performance_insights_enabled = var.performance_insights_enabled
  monitoring_interval          = var.monitoring_interval

  enabled_cloudwatch_logs_exports = var.enabled_cloudwatch_logs_exports

  tags = var.tags

  lifecycle {
    # A public instance with no CIDR allowed is unreachable from outside the
    # VPC, which is never what publicly_accessible was set for.
    precondition {
      condition     = !var.publicly_accessible || !var.create_security_group || length(var.allowed_cidr_blocks) > 0
      error_message = "publicly_accessible is true but allowed_cidr_blocks is empty, so nothing outside the VPC can connect. Add the client address, e.g. [\"203.0.113.4/32\"]."
    }
  }
}
