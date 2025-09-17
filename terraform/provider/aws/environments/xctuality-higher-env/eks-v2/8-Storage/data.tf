

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