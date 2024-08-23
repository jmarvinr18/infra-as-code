

module "key_pair" {
  source   = "../../../../modules/aws/key_pair"
  key_name = var.key_name
  key_path = var.key_path
}

####################################################################
##                  Provision Security Group                      ##
####################################################################

module "toureast_sg" {
  source              = "../../../../modules/aws/sg"
  vpc_id              = var.vpc_id
  security_group_name = "toureast-sg"
  ingress_rules = [{
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    description = ""
    },
    {
      cidr_blocks = ["0.0.0.0/0"]
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      description = ""
    },
    {
      cidr_blocks = ["0.0.0.0/0"]
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      description = ""
    }    
  ]

  tags = {
    "Name"        = "toureast-sg"
    "Environment" = "staging"
    "Release"     = "latest"
    "Created-by"  = "jmarvinr"
  }
}

####################################################################
##                  Provision EC2 Instance                        ##
####################################################################

module "ec2" {
  source          = "../../../../modules/aws/ec2"
  key_pair        = module.key_pair.key_name
  security_groups = [module.toureast_sg.id]
  amis            = var.amis
  subnet_id       = var.subnet_id
  private_key     = "${var.key_path}/${var.private_key}"

  tags = var.tags
}


####################################################################
##                  Install Packages & Softwares                  ##
####################################################################

resource "null_resource" "ansible_provisioner" {
  depends_on = [module.ec2]

  provisioner "remote-exec" {
    connection {
      host        = module.ec2.public_ip
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
            echo ${module.ec2.public_ip} >> ./ansible/inventory.ini
    EOT
  }
  provisioner "local-exec" {
    command     = "ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -T 300 -i inventory.ini -e 'ansible_user=ubuntu' --private-key=${var.key_path}/${var.private_key} -e 'pub_key=${var.key_path}/${var.key_name}' provision.yml -v"
    working_dir = "./ansible"
  }
}