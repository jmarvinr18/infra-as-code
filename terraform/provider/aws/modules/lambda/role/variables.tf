variable "role_name" {
  type = string
}

variable "inline_policies" {
  type = list(object({
    name   = string
    policy = string
  }))
  default = []
}

variable "managed_policy_arns" {
  type    = list(string)
  default = []
}

variable "tags" {
  type    = map(string)
  default = {}
}
