
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

data "aws_iam_role" "node_role" {
  name = var.eks_node_role_name
}

data "aws_eks_cluster" "this" {
  name = var.eks_cluster_name
}

data "aws_eks_cluster_auth" "this" {
  name = var.eks_cluster_name
}