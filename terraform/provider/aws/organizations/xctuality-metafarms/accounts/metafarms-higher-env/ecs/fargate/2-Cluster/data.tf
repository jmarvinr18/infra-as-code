data "aws_iam_role" "ECSTaskExecutionRole" {
  name = "ECSTaskExecutionRole"
}

data "aws_iam_role" "ServiceRoleForECS" {
  name = "ServiceRoleForECS"
}


data "aws_vpc" "this" {
  tags = {
    Name = var.vpc_name
  }
}

data "aws_subnets" "this" {
  filter {
    name   = "tag:Name"
    values = ["metafarms-higher-env-vpc"]
  }  
  filter {
    name   = "tag:Tier"
    values = ["public"]
  }
}