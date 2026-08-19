output "api_id" {
  value = aws_apigatewayv2_api.this.id
}

output "api_arn" {
  value = aws_apigatewayv2_api.this.arn
}

output "api_endpoint" {
  description = "Base endpoint of the API (no stage path)."
  value       = aws_apigatewayv2_api.this.api_endpoint
}

output "execution_arn" {
  value = aws_apigatewayv2_api.this.execution_arn
}

output "stage_name" {
  value = aws_apigatewayv2_stage.this.name
}

output "invoke_url" {
  description = "Full URL to call, stage path included when the stage is not $default."
  value       = aws_apigatewayv2_stage.this.invoke_url
}

output "integration_ids" {
  value = { for k, i in aws_apigatewayv2_integration.this : k => i.id }
}

output "route_ids" {
  value = { for k, r in aws_apigatewayv2_route.this : k => r.id }
}

output "access_log_group_name" {
  value = var.access_logs_enabled ? aws_cloudwatch_log_group.access_logs[0].name : null
}
