data "aws_iam_user" "developer" {
    user_name = var.eks_developer_user_name
}

data "aws_iam_user" "admin" {
  user_name = var.eks_admin_user_name
}

data "aws_eks_cluster" "oidc" {
  name = var.eks_cluster_name
}