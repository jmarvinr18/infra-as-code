module "ecr" {
  source = "../../../modules/ecr"
  repos  = var.repos
}
