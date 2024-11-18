variable "asg_availability_zones" {
  type = list(string)
}

variable "desired_capacity" {
  type = number
}

variable "max_size" {
  type = number
}

variable "min_size" {
  type = number
}

variable "launch_template" {
  type = object({
    id = string
    version = string
  })
}

variable "elb_id" {
  type = string
  default = ""
}

variable "lb_target_group_arn" {
  type = string
}