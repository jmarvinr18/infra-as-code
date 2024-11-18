module "tags" {
  source  = "../../../modules/tags"
  tier    = var.tier
  env     = var.env
  region  = var.region
  purpose = var.purpose
  name    = var.cluster_name
}

module "vpc-data" {
  source = "../../../modules/vpc/data"
  env    = var.env
  tier   = var.tier
}

module "eks" {
  source              = "../../../modules/eks"
  cluster_name        = module.tags.name
  eks_cluster_version = var.eks_cluster_version
  all_subnets         = concat(module.vpc-data.public_subnets, module.vpc-data.private_subnets)
}


# module "private-node1" {
#   source          = "../../../modules/eks/node-group"
#   cluster_name    = module.eks.cluster_name
#   ssh_key         = "${module.tags.name}-auto"
#   node_group_name = "app-private-node1"
#   target_subnets  = module.vpc-data.private_subnets
#   capacity_type   = "ON_DEMAND"
#   instance_types  = ["t3.large"]
#   volume_size     = "70"
#   depends_on = [module.eks]
# }


module "private-node2" {
  source          = "../../../modules/eks/node-group"
  cluster_name    = module.eks.cluster_name
  ssh_key         = "${module.tags.name}-auto"
  node_group_name = "app-private-node2"
  target_subnets  = module.vpc-data.private_subnets
  capacity_type   = "ON_DEMAND"
  instance_types  = ["t3.xlarge"]
  volume_size     = "50"
  depends_on = [module.eks]
}

# module "private-node3" {
#   source          = "../../../modules/eks/node-group"
#   cluster_name    = module.eks.cluster_name
#   ssh_key         = "${module.tags.name}-auto"
#   node_group_name = "app-private-node3"
#   target_subnets  = module.vpc-data.private_subnets
#   capacity_type   = "ON_DEMAND"
#   instance_types  = ["t3.xlarge"]
#   volume_size     = "60"
#   depends_on = [module.eks]
# }


## newly added for alb controller
resource "kubernetes_service_account" "service-account" {
  metadata {
    name = "aws-load-balancer-controller"
    namespace = "kube-system"
    labels = {
        "app.kubernetes.io/name"= "aws-load-balancer-controller"
        "app.kubernetes.io/component"= "controller"
    }
    annotations = {
      "eks.amazonaws.com/role-arn" = module.eks.eks_lb_role_arn
      "eks.amazonaws.com/sts-regional-endpoints" = "true"
    }
  }

  depends_on = [ module.private-node2 ]
}

## newly added for alb controller
resource "helm_release" "alb_controller" {
  name       = "aws-load-balancer-controller"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  namespace  = "kube-system"
  depends_on = [
    kubernetes_service_account.service-account
  ]

  set {
    name  = "region"
    value = "ap-southeast-1"
  }

  set {
    name  = "vpcId"
    value = module.vpc-data.vpc_id
  }

  set {
    name  = "image.repository"
    value = "602401143452.dkr.ecr.ap-southeast-1.amazonaws.com/amazon/aws-load-balancer-controller"
  }

  set {
    name  = "serviceAccount.create"
    value = "false"
  }

  set {
    name  = "serviceAccount.name"
    value = "aws-load-balancer-controller"
  }

  set {
    name  = "clusterName"
    value = "${module.tags.name}"
  }
}

# # t3a.2xlarge - 160.79  (14 hrs util /day)
# # m5a.2xlarge - 183.96  (14 hrs util /day)

# # module "public-node" {
# #   source          = "../../../modules/eks/node-group"
# #   cluster_name    = module.eks.cluster_name
# #   ssh_key         = "eks-test"
# #   node_group_name = "app-public-nodes"
# #   target_subnets  = module.vpc-data.public_subnets
# #   capacity_type   = var.capacity_type
# #   instance_types  = ["t3.medium"]

# #   depends_on = [module.eks]
# # }