resource "aws_eks_cluster" "eks" {
  name     = var.eks_version
  version  = var.eks_version
  role_arn = var.role_arn

  vpc_config {
    endpoint_private_access = var.vpc_config.endpoint_private_access
    endpoint_public_access  = var.vpc_config.endpoint_public_access

    subnet_ids = var.vpc_config.subnet_ids

  }

  access_config {
    authentication_mode                         = var.access_config.authentication_mode
    bootstrap_cluster_creator_admin_permissions = var.access_config.bootstrap_cluster_creator_admin_permissions
  }
  
}
