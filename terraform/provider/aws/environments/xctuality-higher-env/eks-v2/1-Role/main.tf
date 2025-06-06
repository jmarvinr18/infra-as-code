

##### EKS CLUSTER ROLE & POLICIES

module "eks_cluster_role" {
  source = "../../../../modules/iam/role"

  role_name = var.eks_cluster_role_name

  assume_role_policy = var.eks_assume_role_policy

  tags = var.tags

}

module "eks_policy_attachment" {
  source = "../../../../modules/iam/policy_attachment"

  policy_attachments = var.eks_cluster_policy_attachments

  role = module.eks_cluster_role.name
}


##### EKS NODES ROLE & POLICIES

module "eks_nodes_role" {
  source = "../../../../modules/iam/role"

  role_name = var.eks_node_role_name

  assume_role_policy = var.eks_nodes_assume_role_policy

  tags = var.tags
}


module "eks_node_policy_attachment" {
  source             = "../../../../modules/iam/policy_attachment"
  policy_attachments = var.eks_node_policy_attachments

  role = module.eks_nodes_role.name

}


##### EKS LOAD BALANCER CONTROLLER ROLE & POLICIES

module "eks_lbc_role" {
  source = "../../../../modules/iam/role"

  role_name = "eks-lbc-role"

  assume_role_policy = var.eks_pods_service_file_name

  tags = var.tags
}

module "aws_lbc_policy" {
  source           = "../../../../modules/iam/policy"
  name             = var.aws_lbc_policy_name
  policy_file_name = var.lbc_policy_file_name
}


module "aws_lbc_policy_attachment" {
  source             = "../../../../modules/iam/policy_attachment"
  policy_attachments = [module.aws_lbc_policy.arn]

  role = module.eks_nodes_role.name

}


##### EKS CLUSTER AUTO SCALER ROLE & POLICIES

module "cluster_autoscaler_role" {
  source = "../../../../modules/iam/role"

  role_name = "${var.eks_name}-cluster-autoscaler"

  assume_role_policy = var.eks_pods_service_file_name

  tags = var.tags

}

module "cluster_autoscaler_policy" {
  source           = "../../../../modules/iam/policy"
  name             = var.aws_lbc_policy_name
  policy_file_name = var.cluster_autoscaler_policy_file_name
}

module "cluster_autoscaler_policy_attachment" {
  source             = "../../../../modules/iam/policy_attachment"
  policy_attachments = [module.cluster_autoscaler_policy.arn]

  role = module.cluster_autoscaler_role.name

}
