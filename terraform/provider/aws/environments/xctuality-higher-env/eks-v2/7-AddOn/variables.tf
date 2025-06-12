variable "region" {
  type = string
  default = "value"
}


variable "eks_cluster_name" {
  type = string
}
variable "add_ons" {
  type = list(object({
    addon_name = string
    addon_version = string
  }))
}


variable "tags" {
  type = map(string)
}
