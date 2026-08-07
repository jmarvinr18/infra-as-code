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

variable "domain" {
  type = string
}

variable "mail_from_subdomain" {
  type    = string
  default = "mail"
}

variable "mail_from_mx_failure_behavior" {
  type    = string
  default = "UseDefaultValue"
}

variable "create_configuration_set" {
  type    = bool
  default = true
}

variable "configuration_set_name" {
  type    = string
  default = ""
}

variable "smtp_iam_user_name" {
  type = string
}

variable "tags" {
  type    = map(string)
  default = {}
}
