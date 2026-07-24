
#######################################################################
##  Create the organization with all features enabled.               ##
#######################################################################

module "organization" {
  source   = "../../../modules/organizations/organization"
  feature_set = var.feature_set
}


#######################################################################
##  Top-level Organization Unit                                      ##
#######################################################################

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

#######################################################################
##  Create organizational accounts                                   ##
#######################################################################

module "name" {
  source   = "../../../modules/organizations/account"
  role_name = var.role_name
  parent_id = module.clients.id
  close_on_deletion = var.close_on_deletion
  iam_user_access_to_billing = var.iam_user_access_to_billing
  clients = var.clients
}



#######################################################################
##  Service Control Policy Setup                                     ##
#######################################################################

module "scp" {
  source   = "../../../modules/organizations/policy"
  name = var.name
  description = var.description
  type = var.type
  organization_ou_client_id = module.clients.id
  content = var.content
}