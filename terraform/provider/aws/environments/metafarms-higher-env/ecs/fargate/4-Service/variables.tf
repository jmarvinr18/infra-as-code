



#### SERVICE CREATION VARIABLES ####


variable "launch_type" {
  type = string
}

variable "scheduling_strategy" {
  type = string
}
variable "cluster_name" {
  type = string
}
variable "service_name" {
  type = string
}

variable "td_name" {
  type = string
}

variable "container_name" {
  type = string
}

variable "container_port" {
  type = string
}
variable "desired_count" {
  type = number
}

variable "tags" {
  type = map(string)
}

variable "profile" {
  type        = string
  description = "local aws-cli profile name"
}

variable "region" {
  type        = string
  description = "aws region"
}