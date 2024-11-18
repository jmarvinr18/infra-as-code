variable "name" {
  type = string
}

variable "port" {
  type = number
  default = 80
}

variable "protocol" {
  type = string
  default = "HTTP"
}

variable "vpc_id" {
  type = string
}

variable "aws_instance_target_id" {
  type = string
}

variable "instance_target_group_port" {
  type = string
}

variable "health_check" {
  type = object({
    path = string
    port = number
    healthy_threshold = number
    unhealthy_threshold = number
  })
}