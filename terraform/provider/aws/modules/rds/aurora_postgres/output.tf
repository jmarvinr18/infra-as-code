output "cluster_identifier" {
  value = aws_rds_cluster.this.cluster_identifier
}

output "arn" {
  description = "Cluster ARN. Data API callers pass this as resourceArn, and IAM policies scope to it."
  value       = aws_rds_cluster.this.arn
}

output "id" {
  value = aws_rds_cluster.this.id
}

output "endpoint" {
  description = "Writer endpoint hostname."
  value       = aws_rds_cluster.this.endpoint
}

output "reader_endpoint" {
  value = aws_rds_cluster.this.reader_endpoint
}

output "port" {
  value = aws_rds_cluster.this.port
}

output "db_name" {
  value = aws_rds_cluster.this.database_name
}

output "master_username" {
  value = aws_rds_cluster.this.master_username
}

output "master_user_secret_arn" {
  description = "Secrets Manager secret holding the master credentials; null when manage_master_user_password is false."
  value       = try(aws_rds_cluster.this.master_user_secret[0].secret_arn, null)
}

output "http_endpoint_enabled" {
  value = aws_rds_cluster.this.enable_http_endpoint
}

output "security_group_id" {
  value = var.create_security_group ? aws_security_group.this[0].id : null
}

output "subnet_group_name" {
  value = aws_db_subnet_group.this.name
}
