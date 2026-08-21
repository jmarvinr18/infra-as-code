# ─────────────────────────────────────────────────────────────────────────────
# Ingest and process.
#
# One deployment package, five functions. The handlers share common.py, so a
# single archive with a different `handler` per function keeps one copy of the
# database and auth plumbing rather than five that drift apart.
# ─────────────────────────────────────────────────────────────────────────────

data "archive_file" "src" {
  type        = "zip"
  source_dir  = "${path.module}/src"
  output_path = "${path.module}/.build/${local.name}-src.zip"
}

# ─────────────────────────────────────────────────────────────────────────────
# Dead-letter queue.
#
# A synchronous API Gateway invocation has no automatic dead-letter path —
# Lambda's own dead_letter_config only covers asynchronous invocations — so the
# request handlers push failed writes here explicitly. The scheduled functions,
# which are invoked asynchronously, also get it wired as their DLQ.
#
# Retention is the full fourteen days on purpose: the point of the queue is
# that a Friday failure is still there on Monday.
# ─────────────────────────────────────────────────────────────────────────────

module "dlq" {
  source = "../sqs/queue"

  name                       = "${local.name}-dlq"
  message_retention_seconds  = 1209600
  visibility_timeout_seconds = max(var.lambda_timeout, var.embedding_lambda_timeout)

  tags = local.tags
}

# ─────────────────────────────────────────────────────────────────────────────
# IAM.
#
# One role per function, each scoped to the cluster ARN and its secret. No
# wildcard resources: a function that only reads has no write permission, and
# the metrics function cannot invoke Bedrock at all.
# ─────────────────────────────────────────────────────────────────────────────

locals {
  # Both statements are needed together — the Data API authenticates as the
  # secret, so permission to call it is useless without permission to read it.
  data_api_statements = var.create_aurora ? [
    {
      Sid    = "UseDataApi"
      Effect = "Allow"
      Action = [
        "rds-data:ExecuteStatement",
        "rds-data:BatchExecuteStatement",
        "rds-data:BeginTransaction",
        "rds-data:CommitTransaction",
        "rds-data:RollbackTransaction",
      ]
      Resource = [module.aurora[0].arn]
    },
    {
      Sid      = "ReadClusterSecret"
      Effect   = "Allow"
      Action   = ["secretsmanager:GetSecretValue", "secretsmanager:DescribeSecret"]
      Resource = [module.aurora[0].master_user_secret_arn]
    },
  ] : []

  dlq_write_statement = {
    Sid      = "WriteToDeadLetterQueue"
    Effect   = "Allow"
    Action   = ["sqs:SendMessage"]
    Resource = [module.dlq.arn]
  }

  bedrock_model_arns = [
    "arn:aws:bedrock:${var.region}::foundation-model/${var.embedding_model_id}",
    "arn:aws:bedrock:${var.region}::foundation-model/${var.labelling_model_id}",
  ]

  # Functions reached through API Gateway. Keyed so the API module can build
  # one integration per function without repeating the block five times.
  request_functions = {
    usage = {
      handler     = "handlers.usage.lambda_handler"
      description = "Validates, enriches and stores usage events"
      timeout     = var.lambda_timeout
      statements  = concat(local.data_api_statements, [local.dlq_write_statement])
      environment = {}
    }
    feedback = {
      handler     = "handlers.feedback.lambda_handler"
      description = "Decides whether feedback is due and stores submissions"
      timeout     = var.lambda_timeout
      statements  = concat(local.data_api_statements, [local.dlq_write_statement])
      environment = {}
    }
    metrics = {
      handler     = "handlers.metrics.lambda_handler"
      description = "Aggregate queries behind the dashboard and the agent's tools"
      timeout     = var.lambda_timeout
      statements  = local.data_api_statements
      environment = {}
    }
  }
}

module "role" {
  for_each = merge(local.request_functions, local.background_functions)
  source   = "../lambda/role"

  role_name = "${local.name}-${each.key}"

  managed_policy_arns = [
    "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole",
  ]

  inline_policies = length(each.value.statements) == 0 ? [] : [
    {
      name = "${local.name}-${each.key}"
      policy = jsonencode({
        Version   = "2012-10-17"
        Statement = each.value.statements
      })
    }
  ]

  tags = local.tags
}

# ─────────────────────────────────────────────────────────────────────────────
# Functions
# ─────────────────────────────────────────────────────────────────────────────

# Created here rather than left to Lambda's implicit group, which has no
# retention and keeps every log line forever.
resource "aws_cloudwatch_log_group" "function" {
  for_each = merge(local.request_functions, local.background_functions)

  name              = "/aws/lambda/${local.name}-${each.key}"
  retention_in_days = var.log_retention_in_days

  tags = local.tags
}

module "function" {
  for_each = merge(local.request_functions, local.background_functions)
  source   = "../lambda/function"

  function_name = "${local.name}-${each.key}"
  description   = each.value.description
  role_arn      = module.role[each.key].arn
  handler       = each.value.handler
  runtime       = var.lambda_runtime
  architectures = [var.lambda_architecture]

  filename         = data.archive_file.src.output_path
  source_code_hash = data.archive_file.src.output_base64sha256

  timeout     = each.value.timeout
  memory_size = var.lambda_memory_size
  layers      = var.lambda_layers

  environment_variables = merge(local.common_environment, each.value.environment)

  tags = local.tags

  depends_on = [aws_cloudwatch_log_group.function]
}

# ─────────────────────────────────────────────────────────────────────────────
# API Gateway HTTP API.
#
# The API key is checked inside the handlers against a SHA-256 in agent_config,
# not by API Gateway: HTTP APIs have no built-in key store, and putting the
# check in one shared function means the same code path issues, rotates and
# verifies. Throttling is the stage's job and is set below.
# ─────────────────────────────────────────────────────────────────────────────

module "api" {
  source = "../api_gateway/http_api"

  name        = "${local.name}-api"
  description = "AI adoption and feedback tracker — ${var.environment}"

  cors_configuration = var.cors_allow_origins == null ? null : {
    allow_origins = var.cors_allow_origins
    allow_headers = ["content-type", "authorization", "x-api-key", "x-agent-id"]
    allow_methods = ["GET", "POST", "OPTIONS"]
  }

  integrations = {
    for name, fn in merge(local.request_functions, local.routed_background_functions) :
    name => {
      lambda_invoke_arn    = module.function[name].invoke_arn
      lambda_function_name = module.function[name].function_name
      # An HTTP API integration caps at 30s whatever the function's own timeout.
      timeout_milliseconds = min(fn.timeout * 1000, 30000)
    }
  }

  routes = {
    "GET /health"                  = { integration_key = "metrics" }
    "POST /v1/usage"               = { integration_key = "usage" }
    "POST /v1/feedback/check"      = { integration_key = "feedback" }
    "POST /v1/feedback/submit"     = { integration_key = "feedback" }
    "GET /v1/insights"             = { integration_key = "metrics" }
    "GET /v1/metrics/adoption"     = { integration_key = "metrics" }
    "GET /v1/metrics/trend"        = { integration_key = "metrics" }
    "GET /v1/themes"               = { integration_key = "metrics" }
    "POST /v1/insights/regenerate" = { integration_key = "briefing" }
  }

  stage_name            = var.stage_name
  log_retention_in_days = var.log_retention_in_days

  throttling_burst_limit = var.throttling_burst_limit
  throttling_rate_limit  = var.throttling_rate_limit

  # The regenerate route costs one agent invocation per call, so it gets its
  # own, much tighter limit rather than sharing the stage default with a
  # health check.
  route_settings = {
    "POST /v1/insights/regenerate" = {
      throttling_burst_limit = var.regenerate_throttling_burst_limit
      throttling_rate_limit  = var.regenerate_throttling_rate_limit
    }
  }

  tags = local.tags
}
