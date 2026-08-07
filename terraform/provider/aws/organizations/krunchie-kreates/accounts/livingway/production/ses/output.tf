output "domain_identity_arn" {
  value = module.ses.domain_identity_arn
}

# ─── DNS records to add to livingwayapostolics.org ───────────────────────────

output "domain_verification_txt" {
  description = "Add as TXT record: _amazonses.<domain> → value"
  value       = module.ses.domain_verification_token
}

output "dkim_cname_records" {
  description = "Add three CNAME records: <token>._domainkey.<domain> → <token>.dkim.amazonses.com"
  value       = module.ses.dkim_tokens
}

output "mail_from_domain" {
  description = "Add MX record for this subdomain pointing to feedback-smtp.<region>.amazonses.com, priority 10"
  value       = module.ses.mail_from_domain
}

# ─── SMTP connection details ──────────────────────────────────────────────────

output "smtp_endpoint" {
  description = "SMTP server hostname — use port 587 (STARTTLS) or 465 (SSL)"
  value       = "email-smtp.${var.region}.amazonaws.com"
}

output "smtp_username" {
  value = module.ses.smtp_username
}

output "smtp_secret" {
  description = "Convert this to an SMTP password via: aws iam create-smtp-credentials or the SES console → SMTP Settings"
  value       = module.ses.smtp_secret
  sensitive   = true
}
