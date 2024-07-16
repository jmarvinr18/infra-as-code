resource "aws_iam_role" "role_name" {
  name = var.role_name

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  assume_role_policy = jsonencode(var.policy)

  inline_policy {
    name   = var.inline_policy_name
    policy = jsonencode(var.inline_policy)
  }

  tags = var.tags
}