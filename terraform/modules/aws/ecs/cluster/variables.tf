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