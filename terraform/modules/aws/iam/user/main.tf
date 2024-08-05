resource "aws_iam_user" "this" {
  name = var.iam_user_name
  path = var.path

  tags = var.tags
}

resource "aws_iam_access_key" "this" {
  user = aws_iam_user.this.name
}


resource "aws_iam_user_policy" "this" {
  for_each = {for i, policy in var.policy_details : i => policy}

  user   = aws_iam_user.this.name
  name   = each.value.name
  policy = file(each.value.file)
}