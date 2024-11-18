data "aws_eks_cluster" "this" {
  name       = var.cluster_name
  depends_on = [aws_eks_cluster.eks_cluster]
}

data "aws_eks_cluster_auth" "this" {
  name = var.cluster_name
}


## newly added for cluster autoscaler
data "aws_iam_policy_document" "irsa" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"

    principals {
      type = "Federated"
      identifiers = [
        aws_iam_openid_connect_provider.oidc_issuer.arn
      ]
    }
    
    condition {
      test     = "StringEquals"
      variable = "${replace(data.aws_eks_cluster.this.identity[0].oidc[0].issuer, "https://", "")}:sub"
      values   = var.aws_eks_autoscaler_service_accounts
    }
  }
}

data "tls_certificate" "eks" {
  url = data.aws_eks_cluster.this.identity[0].oidc[0].issuer
}
## newly added for cluster autoscaler