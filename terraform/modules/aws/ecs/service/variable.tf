variable "name" {
  type        = string
}

variable "aws_ecs_cluster_id" {
  type        = string
}

variable "aws_ecs_task_definition_arn" {
  type        = string
}

variable "desired_count" {
  type        = number
  default = 3
}

variable "iam_role_arn" {
  type        = string
}

# variable "depends_on" {
#   type        = list(string)
#   default = []
# }
variable "scheduling_strategy" {
  type        = string
  default = "DAEMON"
}
variable "force_new_deployment" {
  type        = bool
  default = true
}
variable "ordered_placement_strategy" {
  type        = map(string)
  default     = {
    "type" = "binpack"
    "field" = "cpu"
  }
}

variable "target_group_arn" {
  type = string
}


variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}