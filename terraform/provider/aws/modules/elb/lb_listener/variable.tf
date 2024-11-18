variable "load_balancer_arn" {
  type = string
}

variable "port" {
  type = string
}

variable "protocol" {
  type = string
}

variable "ssl_policy" {
  type = string
}

variable "certificate_arn" {
  type = string
}

variable "type" {
  type = string
}

variable "target_group_arn" {
  type = string
}


variable "redirect_port" {
  type = string
}
variable "redirect_protocol" {
  type = string
}

variable "redirect_status_code" {
  type = string
}
