resource "aws_key_pair" "jenkins-key" {
  key_name   = "jenkins-key"
  public_key = file("${var.KEY_PATH}/provisioner-key.pub")
}


# data "aws_ami" "packer_image" {
#   most_recent = true

#   filter {
#     name   = "tag:Created-by"
#     values = [var.tags["Created-by"]]
#   }

#   filter {
#     name   = "tag:Environment"
#     values = [var.tags["Environment"]]
#   }

#   filter {
#     name   = "tag:Name"
#     values = [var.tags["Name"]]
#   }

#   owners = ["self"]
# }


resource "aws_security_group" "jenkins-sg" {
  name        = "jenkins-sg"
  description = "Allow TLS inbound traffic and all outbound traffic"
  vpc_id      = var.VPC_ID


  ingress {
    description      = "HTTPS"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  ingress {
    description      = "HTTP"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }
  ingress {
    description      = "SSH"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  depends_on = [var.VPC_ID]

  tags = {
    Name        = var.tags["Name"]
    Environment = var.tags["Environment"]
  }
}

resource "aws_instance" "jenkins" {
  ami               = var.AMIS
  instance_type     = var.INSTANCE_TYPE
  availability_zone = var.ZONE1
  key_name          = aws_key_pair.jenkins-key.key_name
  subnet_id         = var.SUBNET_ID

  vpc_security_group_ids = [aws_security_group.jenkins-sg.id]

  tags = {
    Name        = var.tags["Name"]
    Environment = var.tags["Environment"]
  }

  provisioner "local-exec" {
    interpreter = ["/bin/bash", "-c"]
    command     = <<EOT
            cat /dev/null > ./ansible/inventory.ini
            echo [webserver] >> ./ansible/inventory.ini
            echo ${self.public_ip} >> ./ansible/inventory.ini
    EOT
  }

  connection {
    user        = var.USER
    private_key = file("${var.KEY_PATH}/provisioner-key")
    host        = self.public_ip
  }
}

resource "null_resource" "ansible_provisioner" {
  depends_on = [aws_instance.jenkins]

  provisioner "remote-exec" {
    connection {
      host        = aws_instance.jenkins.public_dns
      user        = "ubuntu"
      private_key = file("${var.KEY_PATH}/provisioner-key")
    }

    inline = ["echo 'connected!'"]
  }
  provisioner "local-exec" {
    command     = "ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -T 300 -i inventory.ini -e 'ansible_user=ubuntu' --private-key=${var.KEY_PATH}/provisioner-key -e 'pub_key=${var.KEY_PATH}/provisioner-key.pub' provision.yml -v"
    working_dir = "./ansible"
  }
}

output "instance_ip_addr" {
  value       = aws_instance.jenkins.public_dns
  description = "The public IP address of the main server instance."
}