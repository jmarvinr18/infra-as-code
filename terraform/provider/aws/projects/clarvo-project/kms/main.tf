data "aws_caller_identity" "me" {}

module "ai_dev_kms" {
  source = "../../../modules/kms"
  kms_alias_name = var.kms_alias_name
  description = var.description
  deletion_window_in_days = var.deletion_window_in_days
  enable_key_rotation = var.enable_key_rotation
  tags = var.tags

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      { 
        Sid = "RootAdmin", 
        Effect = "Allow",
        Principal = { 
          AWS = "arn:aws:iam::${data.aws_caller_identity.me.account_id}:root" 
        },
        Action = "kms:*", 
        Resource = "*" 
      },
      { 
        Sid = "SandboxRoleUse", 
        Effect = "Allow",
        Principal = { 
          AWS = "arn:aws:iam::${data.aws_caller_identity.me.account_id}:role/clarvo-sandbox" 
        },
        Action = ["kms:Encrypt","kms:Decrypt","kms:GenerateDataKey*","kms:DescribeKey","kms:ReEncrypt*"],
        Resource = "*" 
      }
    ]
  })

}