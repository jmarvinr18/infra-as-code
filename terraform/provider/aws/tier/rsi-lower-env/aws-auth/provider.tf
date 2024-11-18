provider "aws" {
  region  = var.region
  # profile = var.profile
}

provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
  token                  = module.eks.aws_eks_cluster_auth_token
}