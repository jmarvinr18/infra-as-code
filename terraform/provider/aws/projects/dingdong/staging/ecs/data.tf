data "aws_security_group" "this" {
  name = "dingdong-sg"
}

data "aws_vpc" "selected" {
  filter {
    name   = "tag:Name"
    values = ["iGo Production VPC"]
  }
}

data "aws_subnets" "selected" {
  filter {
    name   = "tag:Name"
    values = ["public-ap-southeast-1*"]
  }
}


# data "aws_ecs_cluster" "this" {
#   cluster_name = var.cluster_name
# }
# data "aws_iam_role" "this" {
#   count = var.ecs_role_name != "" ? 1 : 0
#   name = var.ecs_role_name

# }

# data "aws_ecs_task_definition" "this" {
#   task_definition = var.td_name
# }

# data "aws_alb_target_group" "this" {
#   name = var.ecs_target_group
# }

# data "aws_instance" "this" {


#   filter {
#     name   = "tag:Name"
#     values = ["ECS-AGENT-RSI"]
#   }
#   filter {
#     name   = "tag:Created-by"
#     values = ["terraform-jmr"]
#   }

# }
