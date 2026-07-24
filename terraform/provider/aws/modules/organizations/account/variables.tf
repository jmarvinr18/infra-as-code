variable "clients" {
  description = "Map of client accounts to create."
  type = map(object({
    email       = string
    environment = string
  }))
}

variable "parent_id" {
  type = string
}

variable "role_name" {
  type = string
}

variable "iam_user_access_to_billing" {
  type = string
}

variable "close_on_deletion" {
  type = bool
}

# variable "tags" {
#   type = map(string)
# }