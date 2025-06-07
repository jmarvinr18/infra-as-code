variable "helm_releases" {
  type = list(object({
      helm_release_name = string
      helm_repository = string
      chart = string
      namespace = string
      create_namespace = bool
      helm_version = string
      helm_values = list(string)
      set = list(object({
        name  = string
        value = string
      }))
  }))
}