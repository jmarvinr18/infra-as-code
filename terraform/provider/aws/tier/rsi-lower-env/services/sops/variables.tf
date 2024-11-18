variable "profile" {
  description = "local aws-cli profile name"
  default     = "rsi-lower"
}

variable "region" {
  description = "aws region"
  default     = "ap-southeast-1"
}

variable "tier" {
  default = "dta"
}

variable "env" {
  default = "lower"
}

variable "purpose" {
  default = "sops"
}

# variable "eks_oidc_root_ca_thumbprint" {
#   type        = string
#   description = "Thumbprint of Root CA for EKS OIDC, Valid until 2037"
#   default     = "9e99a48a9960b14926bb7f3b02e22da2b0ab7280"
# }

variable "aws_eks_cluster_name" {
  description = "EKS cluster name"
  default     = "lower-rsi-infra"
}

variable "aws_eks_service_accounts" {
  type        = set(string)
  description = "EKS service accounts"
  default = [
    "system:serviceaccount:jenkins-pipeline:pipeline"
  ]
}
