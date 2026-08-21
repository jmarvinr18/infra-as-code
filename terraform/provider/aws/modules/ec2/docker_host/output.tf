output "id" {
  value = aws_instance.this.id
}

output "arn" {
  value = aws_instance.this.arn
}

output "private_ip" {
  value = aws_instance.this.private_ip
}

output "public_ip" {
  description = "The Elastic IP when one is attached, otherwise the ephemeral address."
  value       = var.create_eip ? aws_eip.this[0].public_ip : aws_instance.this.public_ip
}

output "public_dns" {
  value = aws_instance.this.public_dns
}

output "security_group_id" {
  value = var.create_security_group ? aws_security_group.this[0].id : null
}

output "iam_role_name" {
  value = var.create_instance_profile ? aws_iam_role.this[0].name : null
}

output "postgres_port" {
  value = var.postgres_port
}

output "postgres_host" {
  description = "Host to put in a SQL client or a Lambda's DB_HOST."
  value       = var.create_eip ? aws_eip.this[0].public_ip : aws_instance.this.public_ip
}

output "connection_string" {
  description = "libpq URI for TablePlus, DBeaver or psql."
  value       = "postgresql://${var.postgres_user}:${var.postgres_password}@${var.create_eip ? aws_eip.this[0].public_ip : aws_instance.this.public_ip}:${var.postgres_port}/${var.postgres_db}"
  sensitive   = true
}

output "session_manager_command" {
  description = "Shell into the host without SSH."
  value       = "aws ssm start-session --target ${aws_instance.this.id}"
}
