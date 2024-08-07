

module "key_pair" {
  source   = "../../../../../modules/aws/key_pair"
  key_name = var.key_name
  key_path = var.key_path
}


####################################################################
##                  Provision EC2 Instance                        ##
####################################################################

module "ec2" {
  source                 = "../../../../../modules/aws/ec2"
  key_pair               = module.key_pair.key_name
  vpc_security_group_ids = var.vpc_security_group_ids
  amis                   = var.amis
  subnet_id              = var.subnet_id
  private_key            = "${var.key_path}/${var.private_key}"
  iam_instance_profile   = var.iam_instance_profile

  tags = var.tags
}


####################################################################
##                  Install Packages & Softwares                  ##
####################################################################

resource "null_resource" "ansible_provisioner" {
  depends_on = [module.ec2]

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
}