

variable "eks_cluster_name" {
  type = string
}


variable "add_ons" {
  type = list(object({
    addon_name = string
    addon_version = string
  }))
}