output "id" {
  value = aws_db_instance.this.id
}

output "arn" {
  value = aws_db_instance.this.arn
}

output "identifier" {
  value = aws_db_instance.this.identifier
}

output "endpoint" {
  description = "host:port"
  value       = aws_db_instance.this.endpoint
}

output "address" {
  description = "Hostname only."
  value       = aws_db_instance.this.address
}

output "port" {
  value = aws_db_instance.this.port
}

output "db_name" {
  value = aws_db_instance.this.db_name
}

output "master_username" {
  value = aws_db_instance.this.username
}

output "master_user_secret_arn" {
  description = "Secrets Manager secret holding the master credentials; null when manage_master_user_password is false."
  value       = try(aws_db_instance.this.master_user_secret[0].secret_arn, null)
}

output "security_group_id" {
  value = var.create_security_group ? aws_security_group.this[0].id : null
}

output "subnet_group_name" {
  value = aws_db_subnet_group.this.name
}

output "parameter_group_name" {
  value = aws_db_instance.this.parameter_group_name
}
