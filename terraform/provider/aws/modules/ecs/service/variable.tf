variable "name" {
  type = string
}

variable "aws_ecs_cluster_id" {
  type = string
}

variable "aws_ecs_task_definition_arn" {
  type = string
}

variable "desired_count" {
  type    = number
}

# variable "iam_role_arn" {
#   type = string
# }

# variable "depends_on" {
#   type        = list(string)
#   default = []
# }
variable "scheduling_strategy" {
  type    = string
}
variable "force_new_deployment" {
  type    = bool
  default = true
}
# variable "ordered_placement_strategy" {
#   type        = map(string)
#   default     = {
#     "type" = "binpack"
#     "field" = "cpu"
#   }
# }

variable "target_group_arn" {
  type = string
}


variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}

variable "launch_type" {
  type = string
}

variable "container_name" {
  type = string
}

variable "container_port" {
  type = number
}

variable "public_subnet_ids" {
  type = list(string)
}
variable "security_groups" {
  type = list(string)
}