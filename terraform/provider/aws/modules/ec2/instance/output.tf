output "instance_ip_address" {
  value       = aws_instance.this.public_ip
  description = "The public IP address of the main server instance."
}

output "id" {
  value = aws_instance.this.id
  description = "Instance ID"
}

output "device_name" {
  value = aws_instance.this.root_block_device.0.device_name
}

output "ebs_volume_size" {
  value = aws_instance.this.root_block_device.0.volume_size
}

output "ebs_volume_type" {
  value = aws_instance.this.root_block_device.0.volume_type
}

output "instance_type" {
  value = aws_instance.this.instance_type
}

output "key_name" {
  value = aws_instance.this.key_name
}

output "ami" {
  value = aws_instance.this.ami
}

output "tags" {
  value = aws_instance.this.tags_all
}

output "security_groups" {
  value = aws_instance.this.security_groups
}

output "subnet_id" {
  value = aws_instance.this.subnet_id
}
#  aws_instance.example_instance.root_block_device.0.device_name