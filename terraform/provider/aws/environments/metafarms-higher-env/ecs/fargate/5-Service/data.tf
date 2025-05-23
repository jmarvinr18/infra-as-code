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
  name = "DINGDONG-TG"
}

# data "external" "name" {
#   program = ["bash", "./target-group-exists.sh"]

#   query = {
#     name = "DINGDONG-TG"
#   }
# }