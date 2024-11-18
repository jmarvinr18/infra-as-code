variable "app_cluster_name" {
  type    = string
  # default = "My Cluster"
}

variable "availability_zones" {
  type = string
  default = "ap-southeast-1"
}

variable "capacity_provider" {
  type = list(string)
}

variable "capacity_provider_name" {
  type = string
}

variable "asg_capacity_provider" {
  type = object({
    name = string
    auto_scaling_group_arn = string
    managed_termination_protection = string

    managed_scaling = object({
      maximum_scaling_step_size = number
      minimum_scaling_step_size = number

      status = string
      target_capacity = number
    })

  })
}