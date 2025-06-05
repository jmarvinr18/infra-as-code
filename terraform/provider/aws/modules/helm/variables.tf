variable "helm_releases" {
  type = list(object({
      helm_release_name = string
      helm_repository = string
      chart = string
      namespace = string
      helm_version = string
      helm_values = string
  }))
}