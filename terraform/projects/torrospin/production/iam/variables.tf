variable "iam_user_name" {
  type = string
}

variable "policy_details" {
  type = list(object({
    name = string
    file = string
  }))
}