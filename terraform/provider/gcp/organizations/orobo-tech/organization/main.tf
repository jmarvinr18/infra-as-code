

#######################################################################
##  Standard labels applied to every project at creation             ##
#######################################################################

module "labels" {
  source   = "../../../modules/labels"
  for_each = toset(var.envs)

  app     = var.app
  env     = each.value
  purpose = var.purpose
  region  = var.region
  name    = format("%s-%s", var.app, each.value)
}


#######################################################################
##  Organization projects: orobo-prod, orobo-staging, orobo-shared   ##
#######################################################################

module "projects" {
  source = "../../../modules/projects/project"

  projects = {
    for env in var.envs : env => {
      project_id   = format("%s-%s", var.app, env)
      project_name = format("%s-%s", var.app, env)
      labels       = module.labels[env].required
    }
  }

  org_id          = var.org_id
  billing_account = var.billing_account
  deletion_policy = var.deletion_policy
}


#######################################################################
##  Baseline apis enabled on each project                            ##
#######################################################################

module "services" {
  source = "../../../modules/projects/services"

  project_ids = module.projects.project_ids
  services    = var.services
}
