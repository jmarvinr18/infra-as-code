variable "app_cluster_name" {
  type    = string
  default = "My Cluster"
}

variable "availability_zones" {
  type = list(string)
}
variable "app_task_name" {
  type    = string
  default = "My Tasks"
}

variable "ecr_repo_url" {
  type    = string
  default = ""
}

variable "container_port" {
  type    = string
  default = ""
}

variable "host_port" {
  type    = string
  default = ""
}

variable "ecs_task_execution_role_name" {
  type    = string
  default = ""
}

variable "application_load_balancer_name" {
  type    = string
  default = "ECS_ALB"
}

variable "target_group_name" {
  type    = string
  default = ""
}

variable "app_service_name" {
  type    = string
  default = ""
}