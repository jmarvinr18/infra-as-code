variable "cluster_id" {
  type        = string
  description = "EKS cluster name"
  default     = ""
}

# variable "cluster_oidc_issuer_url" {
#   type    = string
#   default = ""
# }

variable "region" {
  type    = string
  default = "ap-southeast-1"
}

variable "env" {
  type    = string
  default = ""
}

variable "env_namespace" {
  type    = string
  default = ""
}

variable "cluster-autoscaler" {
  type    = map(string)
  default = {}
}

variable "aws-node-termination-handler" {
  type    = map(string)
  default = {}
}

variable "aws-vpc-cni" {
  type    = map(string)
  default = {}
}

variable "metrics-server" {
  type    = map(string)
  default = {}
}

variable "prometheus-operator" {
  type    = map(string)
  default = {}
}

variable "fluent-bit" {
  type    = map(string)
  default = {}
}

variable "profile" {
  default = ""
}