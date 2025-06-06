

module "eks_cluster" {
  source = "../../../../modules/eks/cluster"

  eks_cluster_name = var.eks_cluster_name
  eks_version = var.eks_version
  role_arn = data.aws_iam_role.cluster_role.arn

  vpc_config = {
    endpoint_private_access =  var.vpc_config.endpoint_private_access
    endpoint_public_access = var.vpc_config.endpoint_public_access
    subnet_ids = [
      data.aws_subnet.private_zone_1.id,
      data.aws_subnet.private_zone_2.id
    ]
  }

  access_config = {
    authentication_mode = var.access_config.authentication_mode
    bootstrap_cluster_creator_admin_permissions = var.access_config.bootstrap_cluster_creator_admin_permissions
  }

  tags = var.tags

}