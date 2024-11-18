variable "cluster_name" {
  type = string
}

variable "eks_cluster_version" {
  type    = string
  default = "1.29"
}

variable "node_group_name" {
  type = string
}

variable "ssh_key" {
  type    = string
  default = "eks-node-key"
}

variable "volume_size" {
  type    = string
  default = "50"
}

variable "capacity_type" {
  type = string
}

variable "instance_types" {
  type = list(string)
}

variable "target_subnets" {
  type = list(string)
}

variable "sysctl" {
  type    = string
  default = ""
}