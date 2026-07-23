resource "aws_codeartifact_repository" "this" {
  repository  = var.repository_name
  domain      = var.domain
  description = var.description


  dynamic "upstream"{
    for_each = var.upstreams
    content {
      repository_name = upstream.value
    }

  }

  tags = var.tags
}