
resource "aws_security_group" "mgcluster_sg" {
  name        = "mongodb_instance_sg"
  description = "Allow incoming connections"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 27017
    to_port     = 27017
    protocol    = "tcp"
    cidr_blocks = var.cidr_list
    description = "Allow incoming MongoDB connections"
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.authorize_remote
    description = "Allow SSH from Terraform CIDR List"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "mongodb_instance_sg"
  }
}

resource "aws_security_group" "mgcluster_alb_sg" {
  name_prefix = "mongodb_alb_sg"
  description = "Allow incoming connections"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 27017
    to_port     = 27017
    protocol    = "tcp"
    cidr_blocks = var.cidr_list
    description = "Allow incoming MongoDB connections"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "mongodb_alb_sg"
  }
}