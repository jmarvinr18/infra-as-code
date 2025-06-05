resource "aws_iam_role_policy" "this" {
  name   = var.name
  policy = file(var.policy_file_name)
  role   = var.role_id
}