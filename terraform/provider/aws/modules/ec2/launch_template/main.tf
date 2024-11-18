
resource "aws_launch_template" "this" {
  name_prefix   = var.name_prefix
  instance_type = var.instance_type
  image_id      = var.image_id
  key_name      = var.key_name

  iam_instance_profile {
    name = var.instance_profile.name
  }

  network_interfaces {
    device_index                  = var.network_interfaces.device_index
    associate_public_ip_address   = var.network_interfaces.associate_public_ip_address
    subnet_id                     = var.network_interfaces.subnet_id  
    security_groups               = var.network_interfaces.security_groups
  }

  block_device_mappings {
    # device_name = aws_instance.example_instance.root_block_device.0.device_name
    device_name = var.block_device_mappings.device_name

    ebs {
      volume_size = var.block_device_mappings.ebs.volume_size
      volume_type = var.block_device_mappings.ebs.volume_type
    }
  }

  lifecycle {
    # Ensure that the launch template is created only after the EC2 instance is fully created
    ignore_changes = [image_id]
  }

  tags = var.tags
}


