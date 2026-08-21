# ─────────────────────────────────────────────────────────────────────────────
# Store — Aurora Serverless v2 Postgres with pgvector, behind the Data API.
#
# One relational database rather than a table per team. The queries this
# project exists to answer — adoption by business group and division, active
# users over time, barriers ranked by frequency — are a GROUP BY here and an
# awkward access pattern in anything key-value.
#
# The extension is enabled by the migration, not by Terraform: pgvector ships
# with the engine but is inert until CREATE EXTENSION vector runs inside the
# database.
# ─────────────────────────────────────────────────────────────────────────────

module "aurora" {
  count  = var.create_aurora ? 1 : 0
  source = "../rds/aurora_postgres"

  cluster_identifier = "${local.name}-pg"
  vpc_id             = local.vpc_id
  subnet_ids         = local.subnet_ids

  engine_version         = var.db_engine_version
  parameter_group_family = var.db_parameter_group_family

  db_name         = var.db_name
  master_username = var.db_master_username

  # RDS owns the master password in Secrets Manager. That keeps it out of state
  # and gives the Data API the secret it authenticates with — the Lambdas never
  # see a password, only two ARNs.
  manage_master_user_password = true
  enable_http_endpoint        = true

  min_capacity             = var.db_min_capacity
  max_capacity             = var.db_max_capacity
  seconds_until_auto_pause = var.db_seconds_until_auto_pause

  publicly_accessible = var.db_publicly_accessible
  allowed_cidr_blocks = var.db_allowed_cidr_blocks

  backup_retention_period = var.db_backup_retention_period
  skip_final_snapshot     = var.db_skip_final_snapshot
  deletion_protection     = var.db_deletion_protection

  tags = local.tags
}

# ─────────────────────────────────────────────────────────────────────────────
# Development store — Postgres + pgvector in Docker on one EC2 instance.
#
# Reachable with an ordinary connection string from a SQL client and from a
# Lambda outside the VPC. The schema migration is baked into the container's
# first-boot init directory, so the host comes up with the same tables as the
# cluster.
# ─────────────────────────────────────────────────────────────────────────────

resource "random_password" "pgvector_ec2" {
  count = var.create_pgvector_ec2 ? 1 : 0

  length  = 32
  special = true
  # Keep the password safe to paste into a libpq URI without escaping.
  override_special = "-_=+"
}

module "pgvector_ec2" {
  count  = var.create_pgvector_ec2 ? 1 : 0
  source = "../ec2/docker_host"

  name      = "${local.name}-pgvector"
  vpc_id    = local.vpc_id
  subnet_id = var.pgvector_ec2_subnet_id != null ? var.pgvector_ec2_subnet_id : tolist(local.subnet_ids)[0]

  instance_type    = var.pgvector_ec2_instance_type
  architecture     = var.pgvector_ec2_architecture
  root_volume_size = var.pgvector_ec2_root_volume_size
  key_name         = var.pgvector_ec2_key_name

  allowed_postgres_cidr_blocks = var.pgvector_ec2_allowed_cidr_blocks
  allowed_ssh_cidr_blocks      = var.pgvector_ec2_key_name != null ? var.pgvector_ec2_allowed_cidr_blocks : []

  postgres_db       = var.db_name
  postgres_user     = var.db_master_username
  postgres_password = random_password.pgvector_ec2[0].result

  # Same migration the cluster gets, applied on the container's first boot.
  extra_initdb_sql = local.schema_sql

  tags = local.tags
}
