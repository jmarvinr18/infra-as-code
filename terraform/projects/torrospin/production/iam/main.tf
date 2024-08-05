module "iam_user" {
  source         = "../../../../modules/aws/iam/user"
  iam_user_name  = var.iam_user_name
  policy_details = var.policy_details
}