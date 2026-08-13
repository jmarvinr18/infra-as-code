variable "region" {
  type    = string
  default = "ap-southeast-1"
}

variable "client" {
  type = string
}

variable "client_account_id" {
  type = string
}

variable "environment" {
  type = string
}

variable "state_machine_name" {
  type = string
}

variable "role_name" {
  type = string
}

variable "type" {
  type    = string
  default = "STANDARD"
}

variable "tags" {
  type    = map(string)
  default = {}
}
