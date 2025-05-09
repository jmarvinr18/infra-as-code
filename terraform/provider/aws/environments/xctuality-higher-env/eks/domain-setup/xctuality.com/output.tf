output "certificate_arn" {
  value       = module.acm.certificate_arn
  description = "ARN of the certificate"
}

output "certificate_authority_arn" {
  value = module.acm.certificate_authority_arn
}

output "certificate_body" {
  value = module.acm.certificate_body
}

output "certificate_chain" {
  value = module.acm.certificate_chain

}