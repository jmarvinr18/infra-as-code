resource "aws_codeartifact_repository" "this" {
  for_each = var.upstream_repos
  
  repository = each.key
  domain     = var.domain

  external_connections {
    external_connection_name = each.value
  }
  tags = var.tags
}