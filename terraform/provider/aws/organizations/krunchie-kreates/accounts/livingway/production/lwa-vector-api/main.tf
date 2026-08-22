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

  # The OpenAPI document is the route contract. Terraform only adds the
  # Lambda integration because the HTTP API module still owns that wiring.
  openapi_spec = yamldecode(file("${path.module}/openapi.yaml"))

  openapi_routes = {
    for route in flatten([
      for path, path_item in local.openapi_spec.paths : [
        for method, operation in path_item : {
          route_key = "${upper(method)} ${path}"
        } if contains(["get", "post", "put", "patch", "delete", "options", "head"], lower(method))
      ]
      ]) : route.route_key => {
      integration_key = "api"
    }
  }

  # Only mint a key when encryption is on and no existing key was supplied.
  create_db_kms_key = var.db_storage_encrypted && var.db_kms_key_id == null && var.db_create_kms_key

  db_kms_key_id = var.db_kms_key_id != null ? var.db_kms_key_id : (
    local.create_db_kms_key ? module.db_kms[0].arn : null
  )
}

module "lambda_sg" {
  source = "../../../../modules/sg"

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
  source = "../../../../modules/kms"

  description             = "RDS storage encryption for ${var.name_prefix}"
  kms_alias_name          = "alias/${var.name_prefix}-rds"
  deletion_window_in_days = var.db_kms_deletion_window_in_days
  enable_key_rotation     = true
  policy                  = data.aws_iam_policy_document.db_kms[0].json

  tags = local.tags
}

module "rds" {
  source = "../../../../modules/rds/postgres"

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
  kms_key_id        = var.db_kms_key_id

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
  source = "../../../../modules/lambda/role"

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

module "usage_function" {
  source = "../../../../modules/lambda/function"

  function_name = "${var.name_prefix}-usage"
  description   = ""
  role_arn      = module.role.arn
  handler       = var.usage_handler
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

module "metric_function" {
  source = "../../../../modules/lambda/function"

  function_name = "${var.name_prefix}-metrics"
  description   = ""
  role_arn      = module.role.arn
  handler       = var.metrics_handler
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

module "briefing_function" {
  source = "../../../../modules/lambda/function"

  function_name = "${var.name_prefix}-briefing"
  description   = ""
  role_arn      = module.role.arn
  handler       = var.briefing_handler
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

module "embedding_function" {
  source = "../../../../modules/lambda/function"

  function_name = "${var.name_prefix}-embedding"
  description   = ""
  role_arn      = module.role.arn
  handler       = var.embedding_handler
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

module "feedback_function" {
  source = "../../../../modules/lambda/function"

  function_name = "${var.name_prefix}-feedback"
  description   = ""
  role_arn      = module.role.arn
  handler       = var.feedback_handler
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

module "bootstrap_function" {
  source = "../../../../modules/lambda/function"

  function_name = "${var.name_prefix}-bootstrap"
  description   = ""
  role_arn      = module.role.arn
  handler       = var.bootstrap_handler
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
# Private API Gateway REST API
# ─────────────────────────────────────────────────────────────────────────────

resource "aws_api_gateway_rest_api" "private" {
  name        = "${var.name_prefix}_api"
  description = "Private REST API for ${var.name_prefix}"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [merge({
      Effect    = "Allow"
      Principal = "*"
      Action    = "execute-api:Invoke"
      Resource  = "execute-api:/*"
      }, length(var.api_gateway_vpc_endpoint_ids) > 0 ? {
      Condition = {
        StringEquals = {
          "aws:SourceVpce" = var.api_gateway_vpc_endpoint_ids
        }
      }
    } : {})]
  })

  endpoint_configuration {
    types            = ["PRIVATE"]
    vpc_endpoint_ids = length(var.api_gateway_vpc_endpoint_ids) > 0 ? var.api_gateway_vpc_endpoint_ids : null
  }

  tags = local.tags
}

resource "aws_api_gateway_resource" "v1" {
  rest_api_id = aws_api_gateway_rest_api.private.id
  parent_id   = aws_api_gateway_rest_api.private.root_resource_id
  path_part   = "v1"
}

resource "aws_api_gateway_resource" "v1_child" {
  for_each = toset(["health", "usage", "feedback", "insights"])

  rest_api_id = aws_api_gateway_rest_api.private.id
  parent_id   = aws_api_gateway_resource.v1.id
  path_part   = each.value
}

resource "aws_api_gateway_resource" "feedback_leaf" {
  for_each = toset(["check", "submit"])

  rest_api_id = aws_api_gateway_rest_api.private.id
  parent_id   = aws_api_gateway_resource.v1_child["feedback"].id
  path_part   = each.value
}

resource "aws_api_gateway_resource" "insights_leaf" {
  for_each = toset(["adoption", "themes", "briefing"])

  rest_api_id = aws_api_gateway_rest_api.private.id
  parent_id   = aws_api_gateway_resource.v1_child["insights"].id
  path_part   = each.value
}

locals {
  api_route_resource_ids = {
    "/v1/health"            = aws_api_gateway_resource.v1_child["health"].id
    "/v1/usage"             = aws_api_gateway_resource.v1_child["usage"].id
    "/v1/feedback/check"    = aws_api_gateway_resource.feedback_leaf["check"].id
    "/v1/feedback/submit"   = aws_api_gateway_resource.feedback_leaf["submit"].id
    "/v1/insights/adoption" = aws_api_gateway_resource.insights_leaf["adoption"].id
    "/v1/insights/themes"   = aws_api_gateway_resource.insights_leaf["themes"].id
    "/v1/insights/briefing" = aws_api_gateway_resource.insights_leaf["briefing"].id
  }

  api_route_functions = {
    "GET /v1/health"           = module.metrics_function.arn
    "POST /v1/usage"           = module.usage_function.arn
    "POST /v1/feedback/check"  = module.feedback_function.arn
    "POST /v1/feedback/submit" = module.feedback_function.arn
    "GET /v1/insights/adoption" = module.metrics_function.arn
    "GET /v1/insights/themes" = module.metrics_function.arn
    "GET /v1/insights/briefing" = module.briefing_function.arn
  }
}

resource "aws_api_gateway_method" "route" {
  for_each = local.openapi_routes

  rest_api_id   = aws_api_gateway_rest_api.private.id
  resource_id   = local.api_route_resource_ids[split(" ", each.key)[1]]
  http_method   = split(" ", each.key)[0]
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "route" {
  for_each = local.openapi_routes

  rest_api_id             = aws_api_gateway_rest_api.private.id
  resource_id             = aws_api_gateway_method.route[each.key].resource_id
  http_method             = aws_api_gateway_method.route[each.key].http_method
  type                    = "AWS_PROXY"
  integration_http_method = "POST"
  uri                     = "arn:aws:apigateway:${var.region}:lambda:path/2015-03-31/functions/${local.api_route_functions[each.key]}/invocations"
}

resource "aws_lambda_permission" "private_api" {
  for_each      = {
    usage    = module.usage_function.function_name
    feedback = module.feedback_function.function_name
    metrics  = module.metrics_function.function_name
    briefing = module.briefing_function.function_name
  }
  statement_id  = "AllowPrivateRestApiInvoke-${each.key}"
  action        = "lambda:InvokeFunction"
  function_name = each.value
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.private.execution_arn}/*/*"
}

resource "aws_api_gateway_deployment" "private" {
  rest_api_id = aws_api_gateway_rest_api.private.id

  triggers = {
    redeployment = sha1(jsonencode([
      local.openapi_spec,
      local.openapi_routes,
      [for route in aws_api_gateway_integration.route : route.id],
    ]))
  }

  depends_on = [aws_api_gateway_integration.route]
}

resource "aws_api_gateway_stage" "private" {
  rest_api_id          = aws_api_gateway_rest_api.private.id
  deployment_id        = aws_api_gateway_deployment.private.id
  stage_name           = var.stage_name
  xray_tracing_enabled = false
  tags                 = local.tags
}
