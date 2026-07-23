data "aws_security_groups" "metafarm_sg" {
  filter {
    name   = "vpc-id"
    values = [var.vpc_id]
  }
}

data "aws_key_pair" "metafarm" {
  key_name = var.key_name
}