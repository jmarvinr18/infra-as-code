output "api_endpoint" {
  description = "Set the SDK's endpoint to this."
  value       = module.adoption_tracker.api_endpoint
}

output "api_invoke_url" {
  value = module.adoption_tracker.api_invoke_url
}

output "routes" {
  value = module.adoption_tracker.routes
}

output "cluster_arn" {
  value = module.adoption_tracker.cluster_arn
}

output "db_secret_arn" {
  value = module.adoption_tracker.db_secret_arn
}

output "db_name" {
  value = module.adoption_tracker.db_name
}

output "db_mode" {
  value = module.adoption_tracker.db_mode
}

output "table_names" {
  value = module.adoption_tracker.table_names
}

output "dead_letter_queue_url" {
  value = module.adoption_tracker.dead_letter_queue_url
}

output "function_names" {
  value = module.adoption_tracker.function_names
}

output "ecr_repository_url" {
  description = "Push the AgentCore image here, then set create_insight_agent = true."
  value       = module.adoption_tracker.ecr_repository_url
}

output "guardrail_id" {
  value = module.adoption_tracker.guardrail_id
}

output "insight_agent_arn" {
  value = module.adoption_tracker.insight_agent_arn
}

# ── Development store ────────────────────────────────────────────────────────

output "pgvector_ec2_host" {
  description = "Host for TablePlus, DBeaver or psql."
  value       = module.adoption_tracker.pgvector_ec2_host
}

output "pgvector_ec2_instance_id" {
  value = module.adoption_tracker.pgvector_ec2_instance_id
}

output "pgvector_ec2_session_manager_command" {
  value = module.adoption_tracker.pgvector_ec2_session_manager_command
}

output "pgvector_ec2_connection_string" {
  description = "terraform output -raw pgvector_ec2_connection_string"
  value       = module.adoption_tracker.pgvector_ec2_connection_string
  sensitive   = true
}

output "pgvector_ec2_password" {
  value     = module.adoption_tracker.pgvector_ec2_password
  sensitive = true
}

output "region" {
  description = "Read by bootstrap-schema.sh and issue-api-key.sh."
  value       = var.region
}
