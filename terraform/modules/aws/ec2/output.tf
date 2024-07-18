output "instance_ip_address" {
  value       = aws_instance.this.public_ip
  description = "The public IP address of the main server instance."
}