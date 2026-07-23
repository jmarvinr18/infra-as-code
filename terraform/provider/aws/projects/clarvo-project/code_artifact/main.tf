
module "ai_artifact_domain" {
  source        = "../../../modules/code_artifact/domain"
  domain = var.domain
  tags = var.tags
}


module "ai_artifact_domain_repository_upstream" {
  source        = "../../../modules/code_artifact/repository/upstream"

  domain = var.domain
  region = var.region
  repository = var.repository
  external_connection_name = var.external_connection_name

  upstream_repos = var.upstream_repos
  

  tags = var.tags
  depends_on = [ module.ai_artifact_domain ]
}


module "ai_artifact_domain_repository_main" {
  source        = "../../../modules/code_artifact/repository/main"

  domain = var.domain
  region = var.region
  repository = var.repository
  description = var.description
  repository_name = var.repository_name
  upstreams = var.upstreams

  # upstream_repository_name = var.upstream_repository_name

  tags = var.tags
  depends_on = [ module.ai_artifact_domain, module.ai_artifact_domain_repository_upstream ]
}