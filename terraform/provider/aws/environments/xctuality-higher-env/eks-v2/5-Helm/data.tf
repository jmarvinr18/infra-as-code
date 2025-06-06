
data "aws_subnet" "public_zone_1" {
  filter {
    name   = "tag:Name"
    values = ["staging-public-ap-southeast-1a"]
  }
}

data "aws_subnet" "public_zone_2" {
  filter {
    name   = "tag:Name"
    values = ["staging-public-ap-southeast-1b"]
  }
}

data "aws_subnet" "private_zone_1" {
  
  filter {
    name   = "tag:Name"
    values = ["staging-private-ap-southeast-1a"]
  }
}

data "aws_subnet" "private_zone_2" {
  filter {
    name   = "tag:Name"
    values = ["staging-private-ap-southeast-1b"]
  }
}

data "aws_vpc" "eks" {
  filter {
    name   = "tag:Name"
    values = ["xctuality-higher-env-eks"]
  }
}

data "aws_iam_role" "lbc-role" {
  name = "eks-lbc-role"
}


data "aws_caller_identity" "this" {}

data "aws_eks_cluster" "this" {
  name = var.eks_cluster_name
}

data "aws_eks_cluster_auth" "this" {
  name = var.eks_cluster_name
}

# data "kubernetes_config_map" "aws-auth" {
#   metadata {
#     name      = "aws-auth"
#     namespace = "kube-system"
#   }
# }
