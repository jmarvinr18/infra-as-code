data "aws_kms_alias" "developers_kms_keys" {
  for_each = var.developers_kms_keys
  name     = "alias/${each.key}"
}

data "aws_iam_policy_document" "developers" {
  statement {
    sid = "AllowViewAccountInfo"
    actions = [
      "iam:GetAccountPasswordPolicy",
      "iam:GetAccountSummary"
    ]
    effect    = "Allow"
    resources = ["*"]
  }

  statement {
    sid = "AllowManageOwnPasswords"
    actions = [
      "iam:ChangePassword",
      "iam:GetUser"
    ]
    effect    = "Allow"
    resources = ["arn:aws:iam::*:user/$${aws:username}"]
  }

  statement {
    sid = "AllowManageOwnAccessKeys"
    actions = [
      "iam:DeleteSSHPublicKey",
      "iam:CreateAccessKey",
      "iam:DeleteAccessKey",
      "iam:ListAccessKeys",
      "iam:UpdateAccessKey"
    ]
    effect    = "Allow"
    resources = ["arn:aws:iam::*:user/$${aws:username}"]
  }

  statement {
    sid = "AllowManageOwnSSHPublicKeys"
    actions = [
      "iam:DeleteSSHPublicKey",
      "iam:GetSSHPublicKey",
      "iam:ListSSHPublicKeys",
      "iam:UpdateSSHPublicKey",
      "iam:UploadSSHPublicKey"
    ]
    effect    = "Allow"
    resources = ["arn:aws:iam::*:user/$${aws:username}"]
  }

  statement {
    sid = "AllowEKSItems"
    actions = [
      "eks:AccessKubernetesApi",
      "eks:DescribeCluster",
      "eks:DescribeNodegroup",
      "eks:ListClusters",
      "eks:ListFargateProfiles",
      "eks:ListNodegroups",
      "eks:ListUpdates",
      "ssm:GetParameter",
    ]
    effect    = "Allow"
    resources = ["*"]
  }

  statement {
    sid    = "AllowPerformanceInsights"
    effect = "Allow"
    actions = [
      "pi:*",
    ]
    resources = ["*"]
  }

  statement {
    sid    = "AllowRDSLogs"
    effect = "Allow"
    actions = [
      "rds:DownloadDBLogFilePortion",
    ]
    resources = ["*"]
  }
}


data "aws_iam_policy_document" "kms" {
  statement {
    sid = "AllowUseKMS"
    actions = [
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:DescribeKey",
      "kms:ReEncrypt*"
    ]
    effect    = "Allow"
    resources = local.developers_kms_keys_arn
  }
}

data "aws_iam_policy_document" "mfa" {
  statement {
    sid = "AllowViewAccountInfo"
    actions = [
      "iam:GetAccountPasswordPolicy",
      "iam:ListVirtualMFADevices"
    ]
    effect    = "Allow"
    resources = ["*"]
  }

  statement {
    sid = "AllowManageOwnVirtualMFADevice"
    actions = [
      "iam:CreateVirtualMFADevice",
      "iam:DeleteVirtualMFADevice"
    ]
    effect    = "Allow"
    resources = ["arn:aws:iam::*:mfa/$${aws:username}"]
  }

  statement {
    sid = "AllowManageOwnUserMFA"
    actions = [
      "iam:DeactivateMFADevice",
      "iam:EnableMFADevice",
      "iam:GetUser",
      "iam:ListMFADevices",
      "iam:ResyncMFADevice"
    ]
    effect    = "Allow"
    resources = ["arn:aws:iam::*:user/$${aws:username}"]
  }

  statement {
    sid = "DenyAllExceptListedIfNoMFA"
    not_actions = [
      "iam:ChangePassword",
      "iam:CreateVirtualMFADevice",
      "iam:EnableMFADevice",
      "iam:GetUser",
      "iam:ListMFADevices",
      "iam:ListVirtualMFADevices",
      "iam:ResyncMFADevice",
      "sts:GetSessionToken"
    ]
    effect    = "Deny"
    resources = ["*"]

    condition {
      test     = "BoolIfExists"
      variable = "aws:MultiFactorAuthPresent"
      values   = ["false"]
    }

    condition {
      test     = "BoolIfExists"
      variable = "aws:ViaAWSService"
      values   = ["false"]
    }
  }
}
