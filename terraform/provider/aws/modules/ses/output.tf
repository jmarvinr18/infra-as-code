output "domain_identity_arn" {
  value = aws_ses_domain_identity.this.arn
}

output "domain_verification_token" {
  description = "TXT record value to add to DNS for domain ownership verification"
  value       = aws_ses_domain_identity.this.verification_token
}

output "dkim_tokens" {
  description = "Three CNAME values to add to DNS for DKIM signing (append ._domainkey.<domain> as the name)"
  value       = aws_ses_domain_dkim.this.dkim_tokens
}

output "mail_from_domain" {
  value = aws_ses_domain_mail_from.this.mail_from_domain
}

output "configuration_set_name" {
  value = var.create_configuration_set ? aws_ses_configuration_set.this[0].name : null
}

output "smtp_username" {
  description = "SMTP username (IAM access key ID)"
  value       = aws_iam_access_key.smtp.id
}

output "smtp_secret" {
  description = "Raw IAM secret key — convert to SMTP password via: aws ses generate-smtp-credentials or the SES console SMTP settings page"
  value       = aws_iam_access_key.smtp.secret
  sensitive   = true
}
