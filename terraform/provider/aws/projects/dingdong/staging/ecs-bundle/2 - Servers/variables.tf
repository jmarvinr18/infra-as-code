#### EC2 INSTANCE CREATION VARIABLES ####


variable "launch_template_name_prefix" {
  type = string
}

variable "aws_key_name" {
  type = string
}
variable "key_name" {
  type = string
}
variable "key_path" {
  type = string
}
variable "key_pair" {
  type = string
}

variable "instance_type" {
  type = string
}

variable "security_group_name" {
  type = string
}

variable "vpc_id" {
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

variable "vpc_security_group_ids" {
  type = list(string)
}
variable "amis" {
  type = string
}
variable "subnet_id" {
  type = string
}
variable "private_key" {
  type = string
}
variable "user" {
  type = string
}
variable "iam_instance_profile" {
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


variable "ami_from_instance_name" {
  type = string
}


#### LOAD BALANCER CREATION VARIABLES ####

variable "target_group_name" {
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