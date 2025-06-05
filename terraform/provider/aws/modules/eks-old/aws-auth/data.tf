data "aws_caller_identity" "this" {}

data "aws_eks_cluster" "this" {
  name = var.cluster
}

data "aws_eks_cluster_auth" "this" {
  name = var.cluster
}

data "kubernetes_config_map" "aws-auth" {
  metadata {
    name      = "aws-auth"
    namespace = "kube-system"
  }
}
