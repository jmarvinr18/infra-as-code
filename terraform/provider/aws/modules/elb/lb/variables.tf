variable "name" {
  type = string
}

variable "internal" {
  type = bool
  default = false
}

variable "load_balancer_type" {
  type = string
  default = "application"
}

variable "security_groups" {
  type = list(string)
}

variable "subnets" {
  type = list(string)
}

variable "enable_deletion_protection" {
  type = bool
  default = true
}

variable "access_logs" {
  type = map(string)
  default = {
    "bucket" = ""
    "prefix" = ""
    "enabled" = true
  }
}
variable "tags" {
  type = map(string)
  default = {
    "name" = ""
  }
}