

# data "aws_iam_policy_document" "this" {
#   statement {
#     effect =   "Allow"

#     principals {
#       type = "Service"
#       identifiers = [ "pods.eks.amazonaws.com" ]
#     }
#     actions = [
#       "sts:AssumeRole",
#       "sts:TagSession",
#     ]
#   }
  
# }

data "aws_eks_cluster_auth" "this" {
  name = var.eks_cluster_name
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
data "aws_eks_cluster" "this" {
  name = var.eks_cluster_name
}

data "aws_iam_openid_connect_provider" "eks" {
  url = data.aws_eks_cluster.this.identity[0].oidc[0].issuer
}

data "aws_iam_policy_document" "efs_csi_driver" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect = "Allow"

    condition {
      test     = "StringEquals"
      variable = "${replace(data.aws_eks_cluster.this.identity[0].oidc[0].issuer, "https://", "")}:sub"
      values   = ["system:serviceaccount:kube-system:efs-csi-controller-sa"]
    }    
    principals {
      type        = "Federated"
      identifiers = [data.aws_iam_openid_connect_provider.eks.arn]
    }
  }


}