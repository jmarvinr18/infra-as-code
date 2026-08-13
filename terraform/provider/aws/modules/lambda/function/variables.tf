variable "function_name" {
  type = string
}

variable "description" {
  type    = string
  default = ""
}

variable "role_arn" {
  type = string
}

variable "handler" {
  type    = string
  default = "lambda_function.lambda_handler"
}

variable "runtime" {
  type    = string
  default = "python3.12"
}

variable "filename" {
  type = string
}

variable "source_code_hash" {
  type = string
}

variable "timeout" {
  type    = number
  default = 30
}

variable "memory_size" {
  type    = number
  default = 128
}

variable "layers" {
  type    = list(string)
  default = []
}

variable "environment_variables" {
  type    = map(string)
  default = {}
}

variable "vpc_config" {
  type = object({
    subnet_ids         = list(string)
    security_group_ids = list(string)
  })
  default = null
}

variable "tags" {
  type    = map(string)
  default = {}
}
