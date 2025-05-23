#### LOAD BALANCER CREATION VARIABLES ####

variable "target_group_name" {
  type = string
}

variable "target_group_port" {
  type = number
}

variable "target_group_protocol" {
  type = string
}

variable "target_type" {
  type = string
}


variable "instance_target_group_port" {
  type = number
}

variable "health_check" {
  type = object({
    path                = string
    port                = string
    healthy_threshold   = number
    unhealthy_threshold = number
  })
}

variable "load_balancer_name" {
  type = string
}


variable "certificate_arn" {
  type = string
}

variable "ssl_policy" {
  type = string
}

variable "elb_listeners" {
  type = list(object({
    port     = string
    protocol = string

    default_action = object({
      type = string

      redirect = object({
        port                 = string
        protocol             = string
        redirect_status_code = string
      })
    })
  }))
}

variable "asg_name" {
  type = string
}

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


variable "tags" {
  type = map(string)
}

variable "profile" {
  type        = string
  description = "local aws-cli profile name"
}

variable "region" {
  type        = string
  description = "aws region"
}