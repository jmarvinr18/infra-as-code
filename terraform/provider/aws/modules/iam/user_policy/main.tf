resource "aws_iam_user_policy" "this" {
  for_each = {for i, policy in var.policy_details : i => policy}

  user   = var.user
  name   = each.value.name
  policy = file(each.value.file)

}