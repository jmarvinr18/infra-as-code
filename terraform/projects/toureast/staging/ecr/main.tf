module "ecr" {
  source = "../../../../modules/aws/ecr"
  repos  = local.ecr_repositories
}