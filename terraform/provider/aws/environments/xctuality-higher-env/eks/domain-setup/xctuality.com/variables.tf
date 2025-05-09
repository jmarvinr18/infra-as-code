variable "domain_name" {
  type = string
}

variable "subject_alternative_names" {
  type = list(string)
}

variable "validation_method" {
  type = string
}

variable "tags" {
  type = map(string)
}

variable "create_before_destroy" {
  type = bool
}

variable "profile" {
  type        = string
  description = "local aws-cli profile name"
}

variable "region" {
  type        = string
  description = "aws region"
}