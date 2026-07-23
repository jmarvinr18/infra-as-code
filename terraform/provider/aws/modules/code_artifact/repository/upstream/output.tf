output "id" {
  value = aws_codeartifact_repository.this
}

output "arn" {
  value = aws_codeartifact_repository.this
}

output "domain_owner" {
  value = aws_codeartifact_repository.this
}

output "repository" {
  value = aws_codeartifact_repository.this
}

# output "domain" {
#   value = aws_codeartifact_repository.this.domain
# }


output "domain" {
  value = length(aws_codeartifact_repository.this) > 0 ? values(aws_codeartifact_repository.this)[0].domain : null
}