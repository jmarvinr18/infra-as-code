module "tags" {
  source = "../../../modules/tags"
  tier   = var.tier
  env    = var.env
  region = var.region
  name   = var.cluster_name
}

module "vpc" {
  source           = "../../../modules/vpc/networking"
  cidr             = var.cidr
  tags             = module.tags.required
  cluster_name     = module.tags.name
  cidr-priv-1a     = var.cidr-priv-1a
  cidr-priv-1b     = var.cidr-priv-1b
  cidr-priv-1c     = var.cidr-priv-1c
  cidr-pub-1a      = var.cidr-pub-1a
  cidr-pub-1b      = var.cidr-pub-1b
  cidr-pub-1c      = var.cidr-pub-1c
  elb_subnet_state = "shared"
}