# ─────────────────────────────────────────────────────────────────────────────
# Network. Falls back to the account's default VPC and all of its subnets so
# the stack stands up without a prior network build — override for anything
# beyond a demo.
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

  # The Lambda only needs Secrets Manager when RDS owns the master password.
  # Its ENIs have no route to the internet, so reaching the API means an
  # interface endpoint (~$7/mo/AZ) — hence the demo default of an injected
  # password instead.
  create_secretsmanager_endpoint = var.use_managed_master_password && var.create_secretsmanager_vpc_endpoint

  endpoint_subnet_ids = length(var.endpoint_subnet_ids) > 0 ? var.endpoint_subnet_ids : local.subnet_ids

  tags = merge(var.tags, { Stack = var.name_prefix })

  # Only mint a key when encryption is on and no existing key was supplied.
  create_db_kms_key = var.db_storage_encrypted && var.db_kms_key_id == null && var.db_create_kms_key

  db_kms_key_id = var.db_kms_key_id != null ? var.db_kms_key_id : (
    local.create_db_kms_key ? module.db_kms[0].arn : null
  )
}

module "lambda_sg" {
  source = "../../../../../../modules/sg"

  security_group_name = "${var.name_prefix}-lambda"
  vpc_id              = local.vpc_id

  ingress_rules = [
    {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
      description = ""
    },
    {
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
      description = ""
    },
    {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
      description = ""
    },
  ]

  egress_rules = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
      description = "Allow all outbound"
    }
  ]

  tags = merge(local.tags, { Name = "${var.name_prefix}-lambda" })
}

# ─────────────────────────────────────────────────────────────────────────────
# Postgres + pgvector
#
# pgvector ships with RDS Postgres 15.2+ but is not active until
# `CREATE EXTENSION vector;` runs inside the database. Either apply
# sql/bootstrap.sql by hand or call the POST /admin/init route once.
# ─────────────────────────────────────────────────────────────────────────────

resource "random_password" "db" {
  count = var.use_managed_master_password ? 0 : 1

  length  = 32
  special = true
  # RDS rejects '/', '@', '"' and space in master passwords.
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

# ─────────────────────────────────────────────────────────────────────────────
# Storage encryption key.
#
# Leaving kms_key_id unset makes RDS fall back to the AWS-managed `aws/rds` key,
# which is created lazily on first use and does not reliably exist in a fresh
# member account — CreateDBInstance then fails with KMSKeyNotAccessibleFault.
# Owning a customer-managed key removes that dependency for ~$1/month. Set
# db_create_kms_key = false to go back to the AWS-managed key, or
# db_storage_encrypted = false for an unencrypted (free) demo instance.
# ─────────────────────────────────────────────────────────────────────────────

data "aws_iam_policy_document" "db_kms" {
  count = local.create_db_kms_key ? 1 : 0

  statement {
    sid    = "EnableAccountAdministration"
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${var.client_account_id}:root"]
    }

    actions   = ["kms:*"]
    resources = ["*"]
  }
}

module "db_kms" {
  count  = local.create_db_kms_key ? 1 : 0
  source = "../../../../../../modules/kms"

  description             = "RDS storage encryption for ${var.name_prefix}"
  kms_alias_name          = "alias/${var.name_prefix}-rds"
  deletion_window_in_days = var.db_kms_deletion_window_in_days
  enable_key_rotation     = true
  policy                  = data.aws_iam_policy_document.db_kms[0].json

  tags = local.tags
}

module "rds" {
  source = "../../../../../../modules/rds/postgres"

  identifier = "${var.name_prefix}pg"
  vpc_id     = local.vpc_id
  subnet_ids = local.subnet_ids

  engine_version         = var.db_engine_version
  parameter_group_family = var.db_parameter_group_family
  instance_class         = var.db_instance_class
  allocated_storage      = var.db_allocated_storage

  db_name         = var.db_name
  master_username = var.db_master_username

  manage_master_user_password = var.use_managed_master_password
  master_password             = var.use_managed_master_password ? null : random_password.db[0].result

  allowed_security_group_ids = [module.lambda_sg.id]

  # Public access is for tools like TablePlus. The instance still only answers
  # the CIDRs listed here — never widen this to 0.0.0.0/0.
  publicly_accessible = var.db_publicly_accessible
  allowed_cidr_blocks = var.db_allowed_cidr_blocks

  storage_encrypted = var.db_storage_encrypted
  kms_key_id        = local.db_kms_key_id

  backup_retention_period = var.db_backup_retention_period
  skip_final_snapshot     = var.db_skip_final_snapshot
  deletion_protection     = var.db_deletion_protection

  tags = local.tags
}

# ─────────────────────────────────────────────────────────────────────────────
# Secrets Manager interface endpoint — only when RDS manages the password.
# ─────────────────────────────────────────────────────────────────────────────

resource "aws_security_group" "secretsmanager_endpoint" {
  count = local.create_secretsmanager_endpoint ? 1 : 0

  name        = "${var.name_prefix}-sm-endpoint"
  description = "HTTPS to the Secrets Manager interface endpoint"
  vpc_id      = local.vpc_id

  tags = merge(local.tags, { Name = "${var.name_prefix}-sm-endpoint" })
}

resource "aws_vpc_security_group_ingress_rule" "secretsmanager_endpoint_https" {
  count = local.create_secretsmanager_endpoint ? 1 : 0

  security_group_id            = aws_security_group.secretsmanager_endpoint[0].id
  description                  = "HTTPS from the function"
  referenced_security_group_id = module.lambda_sg.id
  ip_protocol                  = "tcp"
  from_port                    = 443
  to_port                      = 443
}

resource "aws_vpc_endpoint" "secretsmanager" {
  count = local.create_secretsmanager_endpoint ? 1 : 0

  vpc_id              = local.vpc_id
  service_name        = "com.amazonaws.${var.region}.secretsmanager"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = local.endpoint_subnet_ids
  security_group_ids  = [aws_security_group.secretsmanager_endpoint[0].id]
  private_dns_enabled = true

  tags = merge(local.tags, { Name = "${var.name_prefix}-sm-endpoint" })
}

# ─────────────────────────────────────────────────────────────────────────────
# Lambda
# ─────────────────────────────────────────────────────────────────────────────

data "archive_file" "this" {
  type        = "zip"
  source_dir  = "${path.module}/src"
  output_path = "${path.module}/.build/${var.name_prefix}-api.zip"
}

module "role" {
  source = "../../../../../../modules/lambda/role"

  role_name = "${var.name_prefix}-api-role"

  managed_policy_arns = [
    "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole",
    # Required for the function to create ENIs in the VPC holding the database.
    "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole",
  ]

  inline_policies = var.use_managed_master_password ? [
    {
      name = "read-db-master-secret"
      policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
          {
            Sid    = "ReadRdsManagedSecret"
            Effect = "Allow"
            Action = [
              "secretsmanager:GetSecretValue",
              "secretsmanager:DescribeSecret",
            ]
            Resource = module.rds.master_user_secret_arn
          }
        ]
      })
    }
  ] : []

  tags = local.tags
}

locals {
  lambda_environment = merge(
    {
      DB_HOST = module.rds.address
      DB_PORT = tostring(module.rds.port)
      DB_NAME = module.rds.db_name
      DB_USER = module.rds.master_username
    },
    var.use_managed_master_password
    ? { DB_SECRET_ARN = module.rds.master_user_secret_arn }
    : { DB_PASSWORD = random_password.db[0].result },
    var.environment_variables,
  )
}

module "function" {
  source = "../../../../../../modules/lambda/function"

  function_name = "${var.name_prefix}-api"
  description   = "HTTP API handler backed by Postgres/pgvector"
  role_arn      = module.role.arn
  handler       = var.handler
  runtime       = var.runtime

  filename         = data.archive_file.this.output_path
  source_code_hash = data.archive_file.this.output_base64sha256

  timeout     = var.timeout
  memory_size = var.memory_size
  layers      = var.layers

  vpc_config = {
    subnet_ids         = local.subnet_ids
    security_group_ids = [module.lambda_sg.id]
  }

  environment_variables = local.lambda_environment

  tags = local.tags
}

# ─────────────────────────────────────────────────────────────────────────────
# API Gateway HTTP API
# ─────────────────────────────────────────────────────────────────────────────

module "api" {
  source = "../../../../../../modules/api_gateway/http_api"

  name        = "${var.name_prefix}_api"
  description = "Public entrypoint for ${var.name_prefix}"

  cors_configuration = var.cors_allow_origins == null ? null : {
    allow_origins = var.cors_allow_origins
  }

  integrations = {
    api = {
      lambda_invoke_arn    = module.function.invoke_arn
      lambda_function_name = module.function.function_name
      # HTTP API integrations cap at 30s regardless of the function's own timeout.
      timeout_milliseconds = min(var.timeout * 1000, 30000)
    }
  }

  routes = {
    "GET /health"      = { integration_key = "api" }
    "POST /documents"  = { integration_key = "api" }
    "POST /search"     = { integration_key = "api" }
    "POST /admin/init" = { integration_key = "api", authorization_type = "AWS_IAM" }
  }

  stage_name            = var.stage_name
  log_retention_in_days = var.log_retention_in_days

  throttling_burst_limit = var.throttling_burst_limit
  throttling_rate_limit  = var.throttling_rate_limit

  tags = local.tags
}
