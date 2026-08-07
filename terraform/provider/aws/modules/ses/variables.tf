variable "domain" {
  description = "The domain to register with SES (e.g. example.com)"
  type        = string
}

variable "mail_from_subdomain" {
  description = "Subdomain used as the MAIL FROM domain"
  type        = string
  default     = "mail"
}

variable "mail_from_mx_failure_behavior" {
  description = "Action when MAIL FROM MX record is not found: UseDefaultValue or RejectMessage"
  type        = string
  default     = "UseDefaultValue"
}

variable "create_configuration_set" {
  description = "Whether to create a SES configuration set"
  type        = bool
  default     = true
}

variable "configuration_set_name" {
  description = "Name of the SES configuration set"
  type        = string
  default     = ""
}

variable "smtp_iam_user_name" {
  description = "IAM user name for SMTP authentication"
  type        = string
}

variable "tags" {
  type    = map(string)
  default = {}
}
