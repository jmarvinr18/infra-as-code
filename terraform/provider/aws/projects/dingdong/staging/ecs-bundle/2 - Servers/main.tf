


####################################################################
##                  Retrieve or Create Security Group             ##
####################################################################

module "sg" {
  # count               = length(data.aws_security_groups.existing_sg) == 0 ? 1 : 0
  source              = "../../../../../modules/sg"
  security_group_name = var.security_group_name
  ingress_rules       = var.ingress_rules
  vpc_id              = var.vpc_id
  tags                = var.tags
}


##############################################################
##                  EC2 Instance Creation                   ##
##############################################################



##### Create Key Pair ######

# data "aws_key_pair" "this" {
#   key_name           = var.key_name
#   include_public_key = true

# }

module "key_pair" {
  # count    = length(data.aws_key_pair.this.id) == 0 ? 1 : 0
  source       = "../../../../../modules/key_pair"
  aws_key_name = var.aws_key_name
  key_name     = var.key_name
  key_path     = var.key_path
  tags         = var.tags
}




##### Provision EC2 Instance ######

module "ec2" {
  source          = "../../../../../modules/ec2/instance"
  key_pair        = module.key_pair.key_name
  amis            = var.amis
  instance_type   = var.instance_type
  subnet_id       = var.subnet_id
  private_key     = "${var.key_path}/${var.private_key}"
  security_groups = [module.sg.id]
  vpc_id          = var.vpc_id

  iam_instance_profile = var.iam_instance_profile

  tags = var.tags

}

##### Install Packages & Softwares ######

resource "null_resource" "ansible_provisioner" {
  provisioner "remote-exec" {
    connection {
      host        = module.ec2.instance_ip_address
      user        = var.user
      private_key = file("${var.key_path}/${var.private_key}")
    }

    inline = ["echo 'connected!'"]
  }

  provisioner "local-exec" {
    interpreter = ["/bin/bash", "-c"]
    command     = <<EOT
            cat /dev/null > ./ansible/inventory.ini
            echo [webserver] >> ./ansible/inventory.ini
            echo ${module.ec2.instance_ip_address} >> ./ansible/inventory.ini
    EOT
  }
  provisioner "local-exec" {
    command     = "ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -T 300 -i inventory.ini -e 'ansible_user=ubuntu' --private-key=${var.key_path}/${var.private_key} -e 'pub_key=${var.key_path}/${var.key_name}' provision.yml -v"
    working_dir = "./ansible"
  }

  depends_on = [module.ec2]
}

##### Converting the EC2 instance into an AMI #####

module "ami_from_instance" {
  source = "../../../../../modules/ec2/ami_from_instance"

  name = var.ami_from_instance_name

  source_instance_id = module.ec2.id

  depends_on = [null_resource.ansible_provisioner]
}




##### Converting the EC2 instance into a Launch Template #####
module "launch_template" {
  source      = "../../../../../modules/ec2/launch_template"
  name_prefix = var.launch_template_name_prefix

  instance_profile = {
    name = data.aws_iam_role.this.name
  }

  network_interfaces = {
    device_index                = 0
    associate_public_ip_address = true
    subnet_id                   = module.ec2.subnet_id
    security_groups             = var.vpc_security_group_ids
  }

  block_device_mappings = {
    device_name = module.ec2.device_name
    ebs = {
      volume_size = module.ec2.ebs_volume_size
      volume_type = module.ec2.ebs_volume_type
    }
  }

  instance_type = module.ec2.instance_type
  key_name      = module.ec2.key_name
  image_id      = module.ami_from_instance.id
  tags          = var.tags


  depends_on = [module.ami_from_instance]
}




# ##############################################################
# ##                 Load Balancer Creation                   ##
# ##############################################################



module "target_group" {
  source                     = "../../../../../modules/elb/lb_target_group"
  name                       = var.target_group_name
  vpc_id                     = data.aws_vpc.selected.id
  instance_target_group_port = var.instance_target_group_port
  aws_instance_target_id     = module.ec2.id

  health_check = {
    path                = var.health_check.path
    port                = var.instance_target_group_port
    healthy_threshold   = var.health_check.healthy_threshold
    unhealthy_threshold = var.health_check.unhealthy_threshold
  }
  tags = var.tags

  depends_on = [module.launch_template, module.ec2]
}

module "load_balancer" {
  source                     = "../../../../../modules/elb/lb"
  name                       = var.load_balancer_name
  security_groups            = [data.aws_security_group.this.id]
  subnets                    = [for i in data.aws_subnets.selected.ids : i]
  enable_deletion_protection = false


  access_logs = {
    "bucket"  = "xctuality-bucket"
    "prefix"  = "production"
    "enabled" = false
  }

  tags = var.tags

  depends_on = [module.launch_template]
}

module "listener_and_routing" {
  for_each          = { for i, listener in var.elb_listeners : i => listener }
  source            = "../../../../../modules/elb/lb_listener"
  load_balancer_arn = module.load_balancer.arn

  protocol = each.value.protocol
  port     = each.value.port

  ssl_policy      = var.ssl_policy
  certificate_arn = var.certificate_arn

  type             = each.value.default_action.type
  target_group_arn = module.target_group.arn


  redirect_port        = each.value.default_action.redirect.port
  redirect_protocol    = each.value.default_action.redirect.protocol
  redirect_status_code = each.value.default_action.redirect.redirect_status_code

  depends_on = [module.launch_template]
}

module "asg" {
  source = "../../../../../modules/asg"

  name = var.asg_name
  asg_availability_zones = var.asg_availability_zones
  desired_capacity       = var.desired_capacity
  max_size               = var.max_size
  min_size               = var.min_size

  launch_template = {
    id      = module.launch_template.launch_template_id
    version = module.launch_template.latest_version
  }
  lb_target_group_arn = module.target_group.arn

}
