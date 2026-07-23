variable "tags" {
  type = map(string)
}

variable "ebs_csi_driver_role_name" {
  type = string
}
variable "eks_cluster_name" {
  type = string
}
variable "ebs_csi_driver_encryption_policy" {
  type = string
}

variable "ebs_csi_add_ons" {
  type = list(object({
    addon_name = string
    addon_version = string
  }))
}
variable "region" {
  type = string
}

variable "eks_pods_service_file_name" {
  type = string
}