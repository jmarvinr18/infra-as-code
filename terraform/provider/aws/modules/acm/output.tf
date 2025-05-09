output "certificate_arn" {
  value       = aws_acm_certificate.this.arn
  description = "ARN of the certificate"
}

output "certificate_authority_arn" {
  value       = aws_acm_certificate.this.certificate_authority_arn
}

output "certificate_body" {
  value       = aws_acm_certificate.this.certificate_body
}

output "certificate_chain" {
  value       = aws_acm_certificate.this.certificate_chain

}