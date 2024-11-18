data "aws_caller_identity" "high" {
}


data "aws_iam_policy_document" "kms-key" {
  statement {
    sid       = "Enable IAM User Permissions"
    effect    = "Allow"
    actions   = ["kms:*"]
    resources = ["*"]
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.high.account_id}:root"]
    }
  }
  depends_on = [
    data.aws_caller_identity.high
  ]
}

data "aws_iam_policy_document" "kms" {
  statement {
    sid    = ""
    effect = "Allow"
    actions = [
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:ReEncrypt*"
    ]
    resources = [
      aws_kms_key.sops.arn,
      "${aws_kms_key.sops.arn}/*",
    ]
  }
}

data "aws_eks_cluster" "current" {
  name = var.aws_eks_cluster_name
}

data "aws_iam_openid_connect_provider" "oidc_issuer" {
  url = data.aws_eks_cluster.current.identity[0].oidc[0].issuer
}

data "aws_iam_policy_document" "irsa" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    principals {
      type = "Federated"
      identifiers = [
        data.aws_iam_openid_connect_provider.oidc_issuer.arn
      ]
    }
    condition {
      test     = "StringEquals"
      variable = "${data.aws_eks_cluster.current.identity[0].oidc[0].issuer}:sub"
      values   = var.aws_eks_service_accounts
    }
  }
}
