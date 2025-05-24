variable "name" {
  type = string
}

variable "port" {
  type = number
}

variable "protocol" {
  type = string
}

variable "target_type" {
  type = string
}

variable "vpc_id" {
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

variable "tags" {
  type = map(string)
}