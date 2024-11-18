
module "tags" {
  source  = "../../../../modules/tags"
  tier    = var.tier
  env     = var.env
  region  = var.region
  purpose = var.purpose
  name = var.cluster_name
}

module "ssh" {
  source = "../../../../modules/ssh-key"
  name   = "${module.tags.name}-auto"
}