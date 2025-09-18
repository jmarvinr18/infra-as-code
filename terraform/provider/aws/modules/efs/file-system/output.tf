
output "name" {
    description = "The name of the EFS file system"
    value       = aws_efs_file_system.this.name
}
output "id" {
    description = "The ID of the EFS file system"
    value       = aws_efs_file_system.this.id
}