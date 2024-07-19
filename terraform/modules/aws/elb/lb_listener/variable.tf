variable "load_balancer_arn" {
  type = string
}

variable "port" {
  type = string
  default = "80"
}

variable "protocol" {
  type = string
  default = "HTTP"
}

variable "ssl_policy" {
  type = string
  default = ""  
}

variable "certificate_arn" {
  type = string
  default = ""
}

variable "type" {
  type = string
  default = "forward"
}

variable "target_group_arn" {
  type = string
}

