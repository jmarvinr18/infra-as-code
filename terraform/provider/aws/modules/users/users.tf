resource "aws_iam_user" "user" {
  for_each = local.users
  name     = each.key
}