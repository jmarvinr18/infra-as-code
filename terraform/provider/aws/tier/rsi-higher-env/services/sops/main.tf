module "tags" {
  source  = "../../../../modules/tags"
  tier    = var.tier
  env     = var.env
  region  = var.region
  purpose = var.purpose
}

resource "aws_kms_key" "sops" {
  description             = "KMS Key for SOPS"
  deletion_window_in_days = 7
  policy                  = data.aws_iam_policy_document.kms-key.json
  tags                    = module.tags.required

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_kms_alias" "sops" {
  name          = "alias/sops"
  target_key_id = aws_kms_key.sops.key_id

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_iam_policy" "kms" {
  name        = "kms_for_sops"
  description = "Policy to allow use of KMS Key for SOPS"
  policy      = data.aws_iam_policy_document.kms.json
  tags        = module.tags.required
}

resource "aws_iam_role_policy_attachment" "kms" {
  role       = aws_iam_role.kms.name
  policy_arn = aws_iam_policy.kms.arn
}

resource "aws_iam_role" "kms" {
  name               = "kms"
  assume_role_policy = data.aws_iam_policy_document.irsa.json
  tags               = module.tags.required
}
