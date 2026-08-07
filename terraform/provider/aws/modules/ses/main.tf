resource "aws_ses_domain_identity" "this" {
  domain = var.domain
}

resource "aws_ses_domain_dkim" "this" {
  domain = aws_ses_domain_identity.this.domain
}

resource "aws_ses_domain_mail_from" "this" {
  domain           = aws_ses_domain_identity.this.domain
  mail_from_domain = "${var.mail_from_subdomain}.${var.domain}"

  behavior_on_mx_failure = var.mail_from_mx_failure_behavior
}

resource "aws_ses_configuration_set" "this" {
  count = var.create_configuration_set ? 1 : 0

  name                       = var.configuration_set_name
  reputation_metrics_enabled = true
  sending_enabled            = true
}

# ─────────────────────────────────────────────────────────────────────────────
# SMTP credentials — IAM user with ses:SendRawEmail only.
# SMTP username  = access key ID
# SMTP password  = derived from the secret using AWS's HMAC-SHA256 formula
#                  (run `aws ses generate-smtp-credentials` or use the
#                   SES console to convert; raw secret is output below)
# ─────────────────────────────────────────────────────────────────────────────

resource "aws_iam_user" "smtp" {
  name = var.smtp_iam_user_name
  path = "/"

  tags = var.tags
}

resource "aws_iam_user_policy" "smtp" {
  name = "ses-smtp-send"
  user = aws_iam_user.smtp.name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid      = "AllowSESSendRawEmail"
        Effect   = "Allow"
        Action   = "ses:SendRawEmail"
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_access_key" "smtp" {
  user = aws_iam_user.smtp.name
}
