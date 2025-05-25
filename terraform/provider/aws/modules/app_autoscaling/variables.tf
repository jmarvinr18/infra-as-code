variable "max_capacity" {
  type = number
}

variable "min_capacity" {
  type = number
}

variable "resource_id" {
  type = string
}

variable "scalable_dimension" {
    type = string
    default =   "ecs:service:DesiredCount"
}

variable "service_namespace" {
  type = string
  default = "ecs"
}


variable "aws_appautoscaling_policy_name" {
  type = string
}

variable "policy_type" {
  type = string
#   default = "StepScaling"
}



