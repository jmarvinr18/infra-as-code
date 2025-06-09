variable "region" {
  type = string
  default = "value"
}

variable "eks_cluster_name" {
  type = string
}

variable "access_entries" {
  type = list(object({
    role = string
    principal_arn = string
    kubernetes_groups = list(string)
  }))
}

variable "eks_developer_user_name" {
  type = string
}

variable "eks_admin_user_name" {
  type = string
}

variable "tags" {
  type = map(string)
}