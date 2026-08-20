output "id" {
  value = aws_bedrock_guardrail.this.guardrail_id
}

output "arn" {
  value = aws_bedrock_guardrail.this.guardrail_arn
}

output "version" {
  description = "Published version to pass as guardrailVersion; DRAFT when create_version is false."
  value       = var.create_version ? aws_bedrock_guardrail_version.this[0].version : "DRAFT"
}
