
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


module "key_pair" {
  source   = "../../../../../modules/key_pair"
  key_name = var.key_name
  key_path = var.key_path
  tags     = var.tags
}


####################################################################
##                  Provision EC2 Instance                        ##
####################################################################

module "ec2" {
  source          = "../../../../../modules/ec2/instance"
  key_pair        = module.key_pair.key_name
  amis            = var.amis
  instance_type   = var.instance_type
  subnet_id       = var.subnet_id
  private_key     = "${var.key_path}/${var.private_key}"
  security_groups = [module.sg.id]
  vpc_id          = var.vpc_id

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


####################################################################
##                     Cloudflare Entry                           ##
####################################################################

module "cloudflare" {
  source = "../../../../../modules/cloudflare/dns_record"

  cloudflare_api_token = var.cloudflare_api_token
  zone_id              = var.zone_id
  name                 = var.name
  value                = module.ec2.public_ip
  type                 = var.type
  ttl                  = var.ttl
  proxied              = var.proxied

}
