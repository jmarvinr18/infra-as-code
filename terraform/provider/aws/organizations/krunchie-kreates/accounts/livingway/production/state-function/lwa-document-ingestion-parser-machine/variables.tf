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

variable "source_s3_bucket" {
  type        = string
  description = "S3 bucket containing source documents. The execution role is granted GetObject/PutObject on this bucket."
}

variable "glue_execution_role_arn" {
  type        = string
  description = "ARN of the IAM role passed to Glue Data Quality. The Step Functions role is granted iam:PassRole on this."
}

variable "lambda_function_arn" {
  type        = string
  description = "ARN of the Lambda function this state machine is allowed to invoke."
}

variable "tags" {
  type    = map(string)
  default = {}
}
