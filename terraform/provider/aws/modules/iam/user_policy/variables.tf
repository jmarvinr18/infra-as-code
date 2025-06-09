variable "policy_details" {
  type = list(object({
      name = string
      file = string
  }))
}

variable "user" {
  type = string
}