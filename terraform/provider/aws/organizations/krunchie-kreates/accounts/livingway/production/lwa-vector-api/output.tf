output "api_endpoint" {
  description = "Base URL of the private REST API."
  value       = "https://${aws_api_gateway_rest_api.private.id}.execute-api.${var.region}.amazonaws.com"
}

output "api_invoke_url" {
  description = "URL to call, stage path included."
  value       = "https://${aws_api_gateway_rest_api.private.id}.execute-api.${var.region}.amazonaws.com/${var.stage_name}"
}

output "api_id" {
  value = aws_api_gateway_rest_api.private.id
}

output "api_routes" {
  value = keys(local.openapi_routes)
}

# output "function_name" {
#   value = module.function.function_name
# }

# output "function_arn" {
#   value = module.function.arn
# }

output "lambda_security_group_id" {
  value = module.lambda_sg.id
}

output "db_endpoint" {
  value = module.rds.endpoint
}

output "db_name" {
  value = module.rds.db_name
}

output "db_master_username" {
  value = module.rds.master_username
}

output "db_master_user_secret_arn" {
  description = "Null unless use_managed_master_password is true."
  value       = module.rds.master_user_secret_arn
}

output "db_password" {
  description = "Only set when use_managed_master_password is false."
  value       = var.use_managed_master_password ? null : random_password.db[0].result
  sensitive   = true
}

output "db_security_group_id" {
  value = module.rds.security_group_id
}

output "db_kms_key_arn" {
  description = "Customer-managed key encrypting the instance; null when using the AWS-managed key or no encryption."
  value       = local.db_kms_key_id
}
