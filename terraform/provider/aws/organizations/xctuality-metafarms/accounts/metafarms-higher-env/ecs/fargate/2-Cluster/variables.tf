#### CLUSTER CREATION VARIABLES ####
variable "app_cluster_name" {
  type = string
}

variable "capacity_provider" {
  type = list(string)
}


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


variable "security_group_name" {
  type = string
}
variable "ingress_rules" {
  type = list(object({
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_blocks = list(string)
    description = string
  }))
}

variable "vpc_name" {
  type = string
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