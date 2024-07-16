variable "role_name" {
  type = string
}

variable "inline_policy_name" {
  type = string
}
variable "inline_policy" {}

variable "policy" {}

variable "tags" {
  type = map(string)
  default = {
    "name" = ""
  }
}

