variable "name" {
  description = "Name of the HTTP API."
  type        = string
}

variable "description" {
  type    = string
  default = ""
}

variable "cors_configuration" {
  description = "CORS settings for the API. Leave null to disable CORS entirely."
  type = object({
    allow_origins     = optional(list(string), ["*"])
    allow_methods     = optional(list(string), ["GET", "POST", "OPTIONS"])
    allow_headers     = optional(list(string), ["content-type", "authorization"])
    expose_headers    = optional(list(string), [])
    allow_credentials = optional(bool, false)
    max_age           = optional(number, 300)
  })
  default = null
}

variable "integrations" {
  description = "Lambda proxy integrations, keyed by an arbitrary label referenced from `routes`."
  type = map(object({
    lambda_invoke_arn      = string
    lambda_function_name   = string
    payload_format_version = optional(string, "2.0")
    timeout_milliseconds   = optional(number, 30000)
  }))
  default = {}
}

variable "routes" {
  description = "Routes keyed by route key (e.g. \"GET /health\", \"$default\")."
  type = map(object({
    integration_key    = string
    authorization_type = optional(string, "NONE")
    authorizer_id      = optional(string)
  }))
  default = {}

  validation {
    condition = alltrue([
      for r in values(var.routes) :
      contains(["NONE", "AWS_IAM", "JWT", "CUSTOM"], r.authorization_type)
    ])
    error_message = "authorization_type must be one of NONE, AWS_IAM, JWT, CUSTOM."
  }
}

variable "create_lambda_permissions" {
  description = "Create the lambda:InvokeFunction permission for each integration."
  type        = bool
  default     = true
}

variable "stage_name" {
  description = "Stage name. Use \"$default\" for an endpoint without a stage path prefix."
  type        = string
  default     = "$default"
}

variable "stage_description" {
  type    = string
  default = ""
}

variable "auto_deploy" {
  type    = bool
  default = true
}

variable "access_logs_enabled" {
  description = "Create a CloudWatch log group and emit stage access logs to it."
  type        = bool
  default     = true
}

variable "log_retention_in_days" {
  type    = number
  default = 14
}

variable "detailed_metrics_enabled" {
  description = "Per-route CloudWatch metrics. Off by default — these are billed as custom metrics."
  type        = bool
  default     = false
}

variable "throttling_burst_limit" {
  type    = number
  default = 100
}

variable "throttling_rate_limit" {
  type    = number
  default = 50
}

variable "tags" {
  type    = map(string)
  default = {}
}
