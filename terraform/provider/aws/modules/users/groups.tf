resource "aws_iam_group" "admins" {
  name = "admins"
}

resource "aws_iam_group" "developers" {
  name = "developers"
}


resource "aws_iam_group_membership" "admins" {
  name  = "admins"
  users = local.admins
  group = aws_iam_group.admins.name
  depends_on = [
    aws_iam_group.admins,
    aws_iam_user.user,
  ]
}

resource "aws_iam_group_membership" "developers" {
  name  = "developers"
  users = local.developers
  group = aws_iam_group.developers.name
  depends_on = [
    aws_iam_group.developers,
    aws_iam_user.user,
  ]
}

resource "aws_iam_group_policy_attachment" "admins" {
  group      = aws_iam_group.admins.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

resource "aws_iam_group_policy" "developers" {
  name   = "CustomDevelopersAccess"
  group  = aws_iam_group.developers.name
  policy = data.aws_iam_policy_document.developers.json
}

resource "aws_iam_group_policy" "mfa" {
  name   = "CustomDevelopersMFAAccess"
  group  = aws_iam_group.developers.name
  policy = data.aws_iam_policy_document.mfa.json
}

resource "aws_iam_group_policy" "kms" {
  name   = "CustomKMSAccess"
  group  = aws_iam_group.developers.name
  policy = data.aws_iam_policy_document.kms.json
}

resource "aws_iam_group_policy_attachment" "developers-access" {
  for_each = toset([
    "arn:aws:iam::aws:policy/AmazonEC2ReadOnlyAccess",
    "arn:aws:iam::aws:policy/AmazonRDSReadOnlyAccess",
    "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess",
    "arn:aws:iam::aws:policy/CloudWatchLogsReadOnlyAccess",
    "arn:aws:iam::aws:policy/CloudWatchReadOnlyAccess",
  ])
  group      = aws_iam_group.developers.name
  policy_arn = each.key
}
