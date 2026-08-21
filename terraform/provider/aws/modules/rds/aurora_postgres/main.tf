locals {
  security_group_ids = concat(
    var.create_security_group ? [aws_security_group.this[0].id] : [],
    var.vpc_security_group_ids,
  )
}

resource "aws_db_subnet_group" "this" {
  name       = "${var.cluster_identifier}-subnets"
  subnet_ids = var.subnet_ids

  tags = var.tags
}

# ─────────────────────────────────────────────────────────────────────────────
# Security group — no egress rules; a Postgres cluster only ever answers.
#
# Callers that go through the RDS Data API never touch this: the Data API is a
# regional HTTPS endpoint, so a Lambda using it needs neither a VPC attachment
# nor an ingress rule here. The group exists for the direct-connection paths —
# psql from a bastion, a VPC-attached function, a migration runner.
# ─────────────────────────────────────────────────────────────────────────────

resource "aws_security_group" "this" {
  count = var.create_security_group ? 1 : 0

  name        = "${var.cluster_identifier}-aurora"
  description = "Postgres access for ${var.cluster_identifier}"
  vpc_id      = var.vpc_id

  tags = merge(var.tags, { Name = "${var.cluster_identifier}-aurora" })
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
# Cluster parameter group.
#
# pgvector ships with Aurora PostgreSQL 15.3+ and needs no preloaded library —
# it is enabled per-database with `CREATE EXTENSION vector;` once the cluster is
# up, which the schema bootstrap does.
# ─────────────────────────────────────────────────────────────────────────────

resource "aws_rds_cluster_parameter_group" "this" {
  count = var.create_parameter_group ? 1 : 0

  name        = "${var.cluster_identifier}-cluster-pg"
  family      = var.parameter_group_family
  description = "Cluster parameters for ${var.cluster_identifier}"

  dynamic "parameter" {
    for_each = var.cluster_parameters
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

# ─────────────────────────────────────────────────────────────────────────────
# Serverless v2 cluster.
#
# engine_mode stays "provisioned" — that is what Serverless v2 is, despite the
# name. Capacity comes from serverlessv2_scaling_configuration and the
# db.serverless instance class below. min_capacity = 0 lets the cluster pause
# entirely when idle (Aurora 13.15+/14.12+/15.7+/16.3+); anything above 0 keeps
# it warm and billing.
# ─────────────────────────────────────────────────────────────────────────────

resource "aws_rds_cluster" "this" {
  cluster_identifier = var.cluster_identifier
  engine             = "aurora-postgresql"
  engine_mode        = "provisioned"
  engine_version     = var.engine_version

  database_name   = var.db_name
  master_username = var.master_username
  port            = var.port

  # Either RDS manages the master password in Secrets Manager (default, keeps
  # the secret out of state) or an explicit password is supplied.
  manage_master_user_password = var.manage_master_user_password ? true : null
  master_password             = var.manage_master_user_password ? null : var.master_password

  # The Data API. Without it every caller needs a VPC attachment, a NAT route
  # and a connection pool; with it a plain Lambda signs an HTTPS call instead.
  enable_http_endpoint = var.enable_http_endpoint

  db_subnet_group_name            = aws_db_subnet_group.this.name
  vpc_security_group_ids          = local.security_group_ids
  db_cluster_parameter_group_name = var.create_parameter_group ? aws_rds_cluster_parameter_group.this[0].name : var.parameter_group_name

  storage_encrypted = var.storage_encrypted
  kms_key_id        = var.kms_key_id

  backup_retention_period      = var.backup_retention_period
  preferred_backup_window      = var.backup_window
  preferred_maintenance_window = var.maintenance_window
  copy_tags_to_snapshot        = true

  skip_final_snapshot       = var.skip_final_snapshot
  final_snapshot_identifier = var.skip_final_snapshot ? null : coalesce(var.final_snapshot_identifier, "${var.cluster_identifier}-final")
  deletion_protection       = var.deletion_protection

  apply_immediately               = var.apply_immediately
  enabled_cloudwatch_logs_exports = var.enabled_cloudwatch_logs_exports

  serverlessv2_scaling_configuration {
    min_capacity             = var.min_capacity
    max_capacity             = var.max_capacity
    seconds_until_auto_pause = var.min_capacity == 0 ? var.seconds_until_auto_pause : null
  }

  tags = var.tags

  lifecycle {
    precondition {
      condition     = !var.enable_http_endpoint || var.manage_master_user_password || var.data_api_secret_arn != null
      error_message = "The Data API authenticates with a Secrets Manager secret. Either leave manage_master_user_password true or pass data_api_secret_arn."
    }
  }
}

resource "aws_rds_cluster_instance" "this" {
  count = var.instance_count

  identifier         = "${var.cluster_identifier}-${count.index}"
  cluster_identifier = aws_rds_cluster.this.id
  engine             = aws_rds_cluster.this.engine
  engine_version     = aws_rds_cluster.this.engine_version
  instance_class     = "db.serverless"

  publicly_accessible          = var.publicly_accessible
  db_subnet_group_name         = aws_db_subnet_group.this.name
  performance_insights_enabled = var.performance_insights_enabled
  monitoring_interval          = var.monitoring_interval
  auto_minor_version_upgrade   = var.auto_minor_version_upgrade
  apply_immediately            = var.apply_immediately

  tags = var.tags
}
