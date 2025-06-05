resource "aws_iam_policy" "this" {
  name   = var.name
  policy = file(var.policy_file_name)
  
}