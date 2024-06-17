module "ecrRepo" {
  source        = "../../../../modules/aws/ecr"
  ecr_repo_name = local.ecr_repo_name
}