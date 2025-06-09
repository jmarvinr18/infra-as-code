variable "region" {
  type = string
}

variable "env" {
  type = string
}


variable "eks_assume_role_policy" {
  type = string
}


variable "eks_nodes_assume_role_policy" {
  type = string
}


variable "eks_cluster_role_name" {
  type = string
}

variable "eks_node_role_name" {
  type = string
}
variable "eks_lbc_role_name" {
  type = string
}


variable "tags" {
  type = map(string)
}

variable "eks_cluster_policy_attachments" {
  type = list(string)
}

variable "eks_node_policy_attachments" {
  type = list(string)
}

variable "aws_lbc_policy_name" {
  type = string
}

variable "eks_pods_service_file_name" {
  type = string
}
variable "lbc_policy_file_name" {
  type = string
}

variable "aws_cluster_autoscaler_policy_name" {
  type = string
}

variable "cluster_autoscaler_policy_file_name" {
  type = string
}

variable "eks_admin_policy_name" {
  type = string
}

variable "eks_admin_policy_file_name" {
  type = string
}



variable "eks_developer_policy_name" {
  type = string
}


variable "eks_developer_policy_file_name" {
  type = string
}

variable "eks_developer_user_name" {
  type = string
}

variable "eks_admin_user_name" {
  type = string
}


variable "eks_cluster_name" {
  type = string
}
