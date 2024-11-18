data "template_file" "mongonodes" {
  template = file("${path.module}/templates/provisioning.tpl")
  vars = {
    domain_name = var.domain_name
    mongo_key   = var.mongo_key
    nodes_ips   = var.nodes_ips
    nodes_hosts = var.nodes_hosts
    primary_node = var.primary_node
    mongo_key = var.mongo_key
    root_user = var.root_user
    root_pass = var.root_pass
    admin_user = var.admin_user
    admin_pass = var.admin_pass
    repl_name = var.repl_name
    secondary_node1 = var.secondary_node1
    secondary_node2 = var.secondary_node2
  }
}

output "rendered" {
  value = data.template_file.mongonodes.rendered
}


resource "aws_instance" "web" {
     instance_type = var.instance_type
     ami = var.ami_id
     availability_zone = var.availability_zone
     key_name = var.key_name
     subnet_id = "${var.subnet_id}"
     private_ip = "${var.private_ip}" #172.31.23.41
     #associate_public_ip_address = "true"
     vpc_security_group_ids = [var.security_group_id]
     user_data = data.template_file.mongonodes.rendered
     tags = {
       Name = "${var.prefix}-mongo-${var.domain_name}"
     }

# root disk    
    root_block_device {
    volume_size           = var.volume_size
    volume_type           = "gp2"
    delete_on_termination = true
    encrypted             = false
  }
}  