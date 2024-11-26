data "aws_iam_role" "ECSTaskExecutionRole" {
  name = "ECSTaskExecutionRole"
}

data "aws_iam_role" "ServiceRoleForECS" {
  name = "ServiceRoleForECS"
}

data "aws_autoscaling_group" "name" {
  name = "dingdong-asg"
}

data "aws_lb_target_group" "this" {
  name = "ECSTARGETGROUP"
}