variable "cluster_name" {
  type = string
}

variable "eks_cluster_version" {
  type    = string
  default = "1.29"
}

variable "all_subnets" {
  type = list(string)
}

## newly added for cluster autoscaler service account
variable "aws_eks_autoscaler_service_accounts" {
  type        = set(string)
  description = "EKS cluster autoscaler service account"
  default = [
    "system:serviceaccount:kube-system:cluster-autoscaler"
  ]
}