resource "aws_codeartifact_domain" "this" {
  domain = var.domain
  tags = var.tags
}