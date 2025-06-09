resource "aws_iam_role_policy_attachment" "this" {

  for_each = { for i, policy in var.policy_attachments : i => policy}

  policy_arn = each.value
  role       = var.role
  
}