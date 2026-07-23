


variable "region" {
  type = string
  default = "value"
}

variable "tags" {
  type = map(string)
}

# variable "helm_releases" {
#   type = list(object({
#       helm_release_name = string
#       helm_repository = string
#       chart = string
#       namespace = string
#       helm_version = string
#       helm_values = list(string)
#       set = list(object({
#         name  = string
#         value = string
#       }))
#   }))
# }


variable "eks_cluster_name" {
  type = string
}