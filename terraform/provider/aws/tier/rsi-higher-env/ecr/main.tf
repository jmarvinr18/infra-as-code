module "ecr" {
  source = "../../../../aws/modules/ecr"
  repos  = local.ecr_repositories
}