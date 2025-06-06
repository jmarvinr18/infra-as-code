

module "eks_cluster" {
  source = "../../../../modules/eks/cluster"
  eks_cluster_name = "staging-xct-higher-eks"
  eks_version = "1.32"
  role_arn = ""

  vpc_config = {
    endpoint_private_access =  false
    endpoint_public_access = true
    subnet_ids = [
      data.aws_subnets.private_zone_1.id,
      data.aws_subnets.private_zone_2.id
    ]
  }

  access_config = {
    authentication_mode = "API"
    bootstrap_cluster_creator_admin_permissions = true
  }



  tags = var.tags

}