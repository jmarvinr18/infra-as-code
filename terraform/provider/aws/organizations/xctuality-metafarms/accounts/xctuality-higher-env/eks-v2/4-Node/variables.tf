


variable "region" {
  type = string
  default = "value"
}

variable "tags" {
  type = map(string)
}

variable "eks_node_role_name" {
  type = string
}

variable "eks_cluster_name" {
  type = string
}

variable "eks_version" {
  type = string
}

variable "node_group_name" {
  type = string
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