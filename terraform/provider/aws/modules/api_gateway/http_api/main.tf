resource "aws_apigatewayv2_api" "this" {
  name          = var.name
  description   = var.description
  protocol_type = "HTTP"

  dynamic "cors_configuration" {
    for_each = var.cors_configuration != null ? [var.cors_configuration] : []
    content {
      allow_origins     = cors_configuration.value.allow_origins
      allow_methods     = cors_configuration.value.allow_methods
      allow_headers     = cors_configuration.value.allow_headers
      expose_headers    = cors_configuration.value.expose_headers
      allow_credentials = cors_configuration.value.allow_credentials
      max_age           = cors_configuration.value.max_age
    }
  }

  tags = var.tags
}

# ─────────────────────────────────────────────────────────────────────────────
# Integrations — Lambda proxy (AWS_PROXY, payload format 2.0).
# Keyed by an arbitrary label that routes refer to via integration_key.
# ─────────────────────────────────────────────────────────────────────────────

resource "aws_apigatewayv2_integration" "this" {
  for_each = var.integrations

  api_id                 = aws_apigatewayv2_api.this.id
  integration_type       = "AWS_PROXY"
  integration_method     = "POST"
  integration_uri        = each.value.lambda_invoke_arn
  payload_format_version = each.value.payload_format_version
  timeout_milliseconds   = each.value.timeout_milliseconds
}

resource "aws_lambda_permission" "this" {
  for_each = var.create_lambda_permissions ? var.integrations : {}

  statement_id  = "AllowInvokeFromHttpApi-${replace(each.key, "/[^a-zA-Z0-9_-]/", "-")}"
  action        = "lambda:InvokeFunction"
  function_name = each.value.lambda_function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.this.execution_arn}/*/*"
}

# ─────────────────────────────────────────────────────────────────────────────
# Routes — keyed by route key, e.g. "GET /health" or "$default".
# ─────────────────────────────────────────────────────────────────────────────

resource "aws_apigatewayv2_route" "this" {
  for_each = var.routes

  api_id             = aws_apigatewayv2_api.this.id
  route_key          = each.key
  target             = "integrations/${aws_apigatewayv2_integration.this[each.value.integration_key].id}"
  authorization_type = each.value.authorization_type
  authorizer_id      = each.value.authorizer_id
}

# ─────────────────────────────────────────────────────────────────────────────
# Stage
# ─────────────────────────────────────────────────────────────────────────────

resource "aws_cloudwatch_log_group" "access_logs" {
  count = var.access_logs_enabled ? 1 : 0

  name              = "/aws/apigateway/${var.name}/${var.stage_name}"
  retention_in_days = var.log_retention_in_days

  tags = var.tags
}

resource "aws_apigatewayv2_stage" "this" {
  api_id      = aws_apigatewayv2_api.this.id
  name        = var.stage_name
  description = var.stage_description
  auto_deploy = var.auto_deploy

  dynamic "access_log_settings" {
    for_each = var.access_logs_enabled ? [1] : []
    content {
      destination_arn = aws_cloudwatch_log_group.access_logs[0].arn
      format = jsonencode({
        requestId        = "$context.requestId"
        ip               = "$context.identity.sourceIp"
        requestTime      = "$context.requestTime"
        httpMethod       = "$context.httpMethod"
        routeKey         = "$context.routeKey"
        path             = "$context.path"
        status           = "$context.status"
        protocol         = "$context.protocol"
        responseLength   = "$context.responseLength"
        integrationError = "$context.integrationErrorMessage"
      })
    }
  }

  # Per-route overrides. A route whose backend is expensive — one model
  # invocation per call, say — should not share the stage default with a
  # health check.
  dynamic "route_settings" {
    for_each = var.route_settings
    content {
      route_key                = route_settings.key
      detailed_metrics_enabled = route_settings.value.detailed_metrics_enabled
      throttling_burst_limit   = route_settings.value.throttling_burst_limit
      throttling_rate_limit    = route_settings.value.throttling_rate_limit
    }
  }

  default_route_settings {
    detailed_metrics_enabled = var.detailed_metrics_enabled
    throttling_burst_limit   = var.throttling_burst_limit
    throttling_rate_limit    = var.throttling_rate_limit
  }

  tags = var.tags
}
