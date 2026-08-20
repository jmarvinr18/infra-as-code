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

variable "architectures" {
  description = "arm64 is cheaper per millisecond. x86_64 stays the default so existing callers are unaffected."
  type        = list(string)
  default     = ["x86_64"]
}

variable "reserved_concurrent_executions" {
  description = "-1 leaves the function on the account's unreserved pool."
  type        = number
  default     = -1
}

variable "dead_letter_target_arn" {
  description = "SQS queue or SNS topic for failed asynchronous invocations. Has no effect on synchronous ones."
  type        = string
  default     = null
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
