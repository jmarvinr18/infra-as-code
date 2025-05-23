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

variable "network_mode" {
  type = string
}

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