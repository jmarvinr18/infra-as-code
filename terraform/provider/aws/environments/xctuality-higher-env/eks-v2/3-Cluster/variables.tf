


variable "region" {
  type = string
  default = "value"
}


variable "eks_cluster_name" {
  type = string
}

variable "eks_version" {
  type = string
}

variable "eks_cluster_role_name" {
  type = string
}

variable "vpc_config" {
  type = object({
    endpoint_private_access =  bool
    endpoint_public_access = bool
  })
}

variable "access_config" {
  type = object({
    authentication_mode = string
    bootstrap_cluster_creator_admin_permissions = bool
  })
}

variable "tags" {
  type = map(string)
}
