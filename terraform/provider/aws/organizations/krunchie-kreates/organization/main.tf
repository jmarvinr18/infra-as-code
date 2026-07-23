module "organization" {
  source   = "../../../modules/organizations/organization"
  feature_set = var.feature_set
}


module "clients" {
  source   = "../../../modules/organizations/unit"
  name = "Clients"
  parent_id = module.organization.roots[0].id
}

module "security" {
  source   = "../../../modules/organizations/unit"
  name = "Security"
  parent_id = module.organization.roots[0].id
}

module "sandbox" {
  source   = "../../../modules/organizations/unit"
  name = "Sandbox"
  parent_id = module.organization.roots[0].id
}