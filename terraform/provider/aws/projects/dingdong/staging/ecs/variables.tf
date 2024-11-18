variable "profile" {
  description = "local aws-cli profile name"
  default     = "xctuality"
}

variable "region" {
  description = "aws region"
  default     = "ap-southeast-1"
}


#### CLUSTER CREATION VARIABLES ####
variable "app_cluster_name" {
  type = string
}

variable "capacity_provider" {
  type = list(string)
}


variable "asg_capacity_provider" {
  type = list(object({
    name = string
    auto_scaling_group_provider = object({
      auto_scaling_group_arn         = string
      managed_termination_protection = string

      managed_scaling = object({
        maximum_scaling_step_size = number
        minimum_scaling_step_size = number
        status                    = string
        target_capacity           = number
      })
    })

  }))
}

#### SERVICE CREATION VARIABLES ####

variable "launch_type" {
  type = string
}

variable "service_name" {
  type = string
}

variable "td_name" {
  type = string
}

variable "cluster_name" {
  type = string
}

variable "ecs_role_name" {
  type = string
}
variable "ecs_target_group" {
  type = string
}

variable "container_name" {
  type = string
}

variable "container_port" {
  type = string
}

#### ROLE CREATION VARIABLES ####

variable "inline_policies_files" {
  type = list(object({
    name = string
    file = string
  }))
}

variable "ecs_service_role_policy_name" {
  type = string
}
variable "ecs_service_policy_path" {
  type = string
}

variable "assume_role_policy" {
  type = string
}


#### EC2 INSTANCE CREATION VARIABLES ####


variable "key_name" {
  type = string
}
variable "key_path" {
  type = string
}
variable "key_pair" {
  type = string
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