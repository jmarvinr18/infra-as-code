# ─────────────────────────────────────────────────────────────────────────────
# Ingest
# ─────────────────────────────────────────────────────────────────────────────

output "api_endpoint" {
  description = "Base URL. This is what the SDK's endpoint is set to."
  value       = module.api.api_endpoint
}

output "api_invoke_url" {
  description = "Full URL including the stage path when the stage is not $default."
  value       = module.api.invoke_url
}

output "api_id" {
  value = module.api.api_id
}

output "routes" {
  description = "Every route this deployment answers."
  value       = keys(module.api.route_ids)
}

output "function_names" {
  value = { for k, f in module.function : k => f.function_name }
}

output "function_arns" {
  value = { for k, f in module.function : k => f.arn }
}

output "role_arns" {
  value = { for k, r in module.role : k => r.arn }
}

output "dead_letter_queue_url" {
  description = "Where failed writes and undeliverable scheduled invocations land."
  value       = module.dlq.url
}

output "dead_letter_queue_arn" {
  value = module.dlq.arn
}

# ─────────────────────────────────────────────────────────────────────────────
# Store
# ─────────────────────────────────────────────────────────────────────────────

output "cluster_arn" {
  description = "Data API resourceArn. Also what the Lambda policies are scoped to."
  value       = local.cluster_arn
}

output "cluster_endpoint" {
  value = var.create_aurora ? module.aurora[0].endpoint : null
}

output "db_secret_arn" {
  description = "Secrets Manager secret the Data API authenticates with."
  value       = local.db_secret_arn
}

output "db_name" {
  value = var.db_name
}

output "table_names" {
  description = "Physical table names in this deployment. A second apply with different values does not collide with this one."
  value       = local.tables
}

output "schema_sql" {
  description = "The rendered migration. Apply it with the Data API, psql, or the account stack's bootstrap script — it is idempotent."
  value       = local.schema_sql
}

output "db_mode" {
  description = "Which store the functions are talking to: data_api or ec2."
  value       = local.db_mode
}

# ─────────────────────────────────────────────────────────────────────────────
# Development store
# ─────────────────────────────────────────────────────────────────────────────

output "pgvector_ec2_host" {
  description = "Public address of the Docker host, for TablePlus, DBeaver or psql."
  value       = var.create_pgvector_ec2 ? module.pgvector_ec2[0].postgres_host : null
}

output "pgvector_ec2_instance_id" {
  value = var.create_pgvector_ec2 ? module.pgvector_ec2[0].id : null
}

output "pgvector_ec2_connection_string" {
  description = "Paste straight into a SQL client."
  value       = var.create_pgvector_ec2 ? module.pgvector_ec2[0].connection_string : null
  sensitive   = true
}

output "pgvector_ec2_password" {
  value     = var.create_pgvector_ec2 ? random_password.pgvector_ec2[0].result : null
  sensitive = true
}

output "pgvector_ec2_session_manager_command" {
  value = var.create_pgvector_ec2 ? module.pgvector_ec2[0].session_manager_command : null
}

# ─────────────────────────────────────────────────────────────────────────────
# Insight
# ─────────────────────────────────────────────────────────────────────────────

output "ecr_repository_url" {
  description = "Push the AgentCore container image here, then set create_insight_agent = true."
  value       = var.create_ecr_repository ? aws_ecr_repository.insight_agent[0].repository_url : null
}

output "guardrail_id" {
  value = var.create_guardrail ? module.guardrail[0].id : null
}

output "guardrail_version" {
  value = var.create_guardrail ? module.guardrail[0].version : null
}

output "insight_agent_arn" {
  value = var.create_insight_agent ? module.insight_agent[0].arn : null
}

output "schedule_rule_names" {
  value = { for k, r in module.schedule : k => r.name }
}
