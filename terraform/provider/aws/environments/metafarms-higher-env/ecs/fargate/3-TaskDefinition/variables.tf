


#### SERVICE CREATION VARIABLES ####

variable "network_mode" {
  type = string
}

variable "td_name" {
  type = string
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