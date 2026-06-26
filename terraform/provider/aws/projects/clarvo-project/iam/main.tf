data "aws_caller_identity" "me" {}

module "ai_developer_user" {
  source        = "../../../modules/iam/user"
  iam_user_name = var.developer_username
  tags = var.tags
}


module "ai_dev_user_role" {
  source                  = "../../../modules/iam/role"
  role_name               = "ai_dev_user_role"
  assume_role_policy_type = "string"
  assume_role_policy      = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { AWS = "arn:aws:iam::${data.aws_caller_identity.me.account_id}:user/${module.ai_developer_user.name}" }
      Action    = "sts:AssumeRole"
      Condition = { Bool = { "aws:MultiFactorAuthPresent" = "true" } }
    }]
  })

  tags = var.tags
}

module "ai_dev_trust_policy" {
  source = "../../../modules/iam/role_policy"
  role_id = module.ai_dev_user_role.id
  name = "clarvo-sandbox-permissions"
  policy_type = "file"
  policy_file_name = "/mnt/d/Users/RouVin/Documents/xctuality/devops/infra-as-code/terraform/provider/aws/projects/clarvo-project/policies/sandbox-permissions.json"
}