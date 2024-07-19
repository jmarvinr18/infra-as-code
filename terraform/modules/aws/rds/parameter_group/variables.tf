variable "name" {
  type = string
}

variable "family" {
  type = string
}

variable "parameters" {
  type = list(object({
    name  = string
    value = string
  }))
}