variable "name" {
  type = string
}
variable "auto_scaling_group_arn" {
  type = string
}

variable "managed_termination_protection" {
  type    = string
  default = "ENABLED"
}

variable "maximum_scaling_step_size" {
  type    = number
  default = 1000
}

variable "minimum_scaling_step_size" {
  type    = number
  default = 1
}
variable "status" {
  type    = number
  default = "ENABLED"
}

variable "target_capacity" {
  type    = number
  default = 10
}

variable "cluster_name" {
  type = string
}
