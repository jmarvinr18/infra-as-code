variable "budget_name" {
  type = string
}

variable "billing_account" {
  description = "Billing account id. Applying needs roles/billing.admin on it."
  type        = string
}

variable "monthly_limit" {
  description = "Monthly cost limit in whole currency units"
  type        = number
}

variable "limit_unit" {
  type = string
}

variable "monitoring_project" {
  description = "Project hosting the email notification channels"
  type        = string
}

variable "notification_emails" {
  type = list(string)
}

variable "projects" {
  description = "projects/<number> entries. Empty covers the whole billing account."
  type        = list(string)
}

variable "app" {
  type = string
}

variable "environment" {
  type = string
}

variable "region" {
  type = string
}

variable "notifications" {
  type = list(object({
    threshold_percent = number
    spend_basis       = string
  }))
}
