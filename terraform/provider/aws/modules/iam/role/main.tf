resource "aws_iam_instance_profile" "this" {
  name = var.role_name
  role = aws_iam_role.this.name
}

resource "aws_iam_role" "this" {
  name = var.role_name

  assume_role_policy = file(var.assume_role_policy)

  dynamic "inline_policy" {
    for_each = [for rule in var.inline_policy : rule if rule.name != ""]

    content {
        name   = inline_policy.value.name
        policy = file(inline_policy.value.file)
    }
  }

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "this" {
  count      = var.policy_arn != "" ? 1 : 0
  role       = aws_iam_role.this.name
  policy_arn = var.policy_arn
}