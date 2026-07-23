data "aws_iam_role" "ECSTaskExecutionRole" {
  name = "ECSTaskExecutionRole"
}

data "aws_iam_role" "ServiceRoleForECS" {
  name = "ServiceRoleForECS"
}


