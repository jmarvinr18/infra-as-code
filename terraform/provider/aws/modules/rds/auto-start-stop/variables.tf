
variable "function_name" {
  description = "The name of the Lambda function"
  type        = string
}

variable "handler" {
  description = "The Lambda function handler"
  type        = string
}

variable "runtime" {
  description = "The runtime environment for the Lambda function"
  type        = string
}

variable "timeout" {
  description = "The timeout value for the Lambda function"
  type        = number
}

variable "environment" {
  description = "The environment variables for the Lambda function"
  type        = map
}