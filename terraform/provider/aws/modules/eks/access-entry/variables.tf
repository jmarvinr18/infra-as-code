

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