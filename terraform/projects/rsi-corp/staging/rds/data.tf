
data "aws_subnets" "this" {
  filter {
    name   = "vpc-id"
    values = [var.vpc_id]
  }
}

data "aws_security_groups" "this" {
  filter {
    name   = "vpc-id"
    values = [var.vpc_id]
  }
}