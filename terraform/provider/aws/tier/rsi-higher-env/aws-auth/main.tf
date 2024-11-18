module "tags" {
  source = "../../../modules/tags"
  tier   = var.tier
  env    = var.env
  region = var.region
  name   = "higher-rsi-infra"
}

module "eks" {
  source  = "../../../modules/eks/data"
  cluster = module.tags.name
}

module "aws-auth-config-map" {
  source  = "../../../modules/eks/aws-auth"
  cluster = module.eks.cluster.name
  roles = ["AWSReservedSSO_AdministratorAccess_9d238ad90f02dab4"]
  admins = [
    "drey.millena",
    "marvin.ramoda"
  ]
  devs = [
    "jimboy.balan",
  ]
}

resource "kubernetes_config_map" "aws-auth" {
  data = module.aws-auth-config-map.aws_auth_configmap_data

  metadata {
    name      = "aws-auth"
    namespace = "kube-system"
  }

  lifecycle {
    prevent_destroy = true
  }
}


