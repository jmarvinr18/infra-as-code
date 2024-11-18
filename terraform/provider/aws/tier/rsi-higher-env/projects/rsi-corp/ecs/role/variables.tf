variable "inline_policies_files" {
  type = list(object({
      name = string
      file = string
  }))
}

variable "assume_role_policy" {
  type = string
}
