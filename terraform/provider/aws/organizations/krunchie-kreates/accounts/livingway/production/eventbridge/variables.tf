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

variable "rule_name" {
  type = string
}

variable "rule_description" {
  type    = string
  default = ""
}

variable "event_bus_name" {
  type    = string
  default = "default"
}

variable "event_pattern" {
  type = string
}

variable "rule_state" {
  type    = string
  default = "ENABLED"
}

variable "target_id" {
  type = string
}

variable "lambda_function_arn" {
  type        = string
  description = "ARN of the Lambda function to invoke."
}

variable "lambda_function_name" {
  type        = string
  description = "Name of the Lambda function (used for the resource-based permission)."
}

variable "tags" {
  type    = map(string)
  default = {}
}
