variable "app_task_family" {
  type    = string
  default = "service"
}

variable "task_definition" {}

variable "ecs_task_execution_role_arn" {
  type = string
}

variable "requires_compatibilities" {
  type = list(string)
  default = [ "EC2" ]
}

variable "network_mode" {
  type = string
  default = "bridge"
}

variable "memory" {
  type = number
  default = 512
}

variable "cpu" {
  type = number
  default = 256
}