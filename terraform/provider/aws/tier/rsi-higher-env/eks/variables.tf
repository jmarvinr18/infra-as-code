variable "profile" {
  description = "local aws-cli profile name"
  default     = "rsi-higher"
}

variable "region" {
  description = "aws region"
  default     = "ap-southeast-1"
}

variable "tier" {
  default = "high"
}

variable "env" {
  default = "higher"
}

variable "purpose" {
  default = "apps"
}

variable "cluster_name" {
  type = string
  default = "higher-rsi-infra"
}

variable "eks_cluster_version" {
  default = "1.29"
}

variable "capacity_type" {
  default = "SPOT"
}