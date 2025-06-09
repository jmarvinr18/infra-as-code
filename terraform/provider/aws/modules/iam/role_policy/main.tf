resource "aws_iam_role_policy" "this" {
  name   = var.name
  policy =  var.policy_type == "string" ? var.policy_file_name : file(var.policy_file_name)
  role   = var.role_id
}