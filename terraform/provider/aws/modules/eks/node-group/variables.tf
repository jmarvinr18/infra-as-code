variable "cluster_name" {
  type = string
}

variable "version" {
  type = string
}

variable "node_group_name" {
  type = string
}

variable "node_role_arn" {
  type = string
}

variable "subnet_ids" {
  type = list(string)
}

variable "capacity_type" {
  type = string
}

variable "instance_types" {
  type = list(string)
}

variable "scaling_config" {
  type = object({
    desired_size = number
    max_size = number
    min_size = number
  })
}

variable "update_config" {
  type = object({
    max_unavailable = number
  })
}

variable "labels" {
  type = object({
    role = string
  })
}

variable "tags" {
  type = map(string)
}
