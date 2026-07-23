# output "arn" {
#   value = module.ai_artifact_domain_repository.arn
# }

# output "repository" {
#   value = module.ai_artifact_domain_repository.repository
# }

# output "repository_count" {
#   value = module.ai_artifact_domain.repository_count
# }

# output "domain_id" {
#   value = module.ai_artifact_domain.id
# }

# output "domain_owner" {
#   value = module.ai_artifact_domain.owner
# }

output "endpoint"  {
  value = "aws codeartifact login --tool pip --domain clarvo --repository clarvo-pkgs --region ${var.region}"
}