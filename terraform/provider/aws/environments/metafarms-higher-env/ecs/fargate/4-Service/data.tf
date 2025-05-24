data "aws_iam_role" "ECSTaskExecutionRole" {
  name = "ECSTaskExecutionRole"
}

data "aws_iam_role" "ServiceRoleForECS" {
  name = "ServiceRoleForECS"
}


data "aws_ecs_cluster" "this" {
  cluster_name = var.cluster_name
}

data "aws_ecs_task_definition" "this" {
  task_definition = var.td_name
}


data "aws_lb_target_group" "this" {
  tags = var.tags
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

data "aws_security_groups" "this" {
  filter {
    name   = "tag:Name"
    values = ["metafarms-production-ecs"]
  }  
}