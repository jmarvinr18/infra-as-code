variable "budget_name" {
  type = string
}

variable "billing_account" {
  description = "Billing account the budget is scoped to. Applying needs roles/billing.admin on it."
  type        = string
}

variable "monitoring_project" {
  description = "Project that hosts the email notification channels"
  type        = string
}

variable "monthly_limit" {
  description = "Monthly cost limit in whole currency units"
  type        = number
}

variable "limit_unit" {
  type    = string
  default = "USD"
}

variable "calendar_period" {
  type    = string
  default = "MONTH"
}

variable "projects" {
  description = "Projects the budget covers as projects/<number>. Empty covers the whole billing account."
  type        = list(string)
  default     = []
}

variable "notification_emails" {
  description = "Emails to raise an email notification channel for"
  type        = list(string)
  default     = []
}

variable "additional_notification_channels" {
  description = "Ids of already existing monitoring notification channels"
  type        = list(string)
  default     = []
}

variable "notifications" {
  description = "Percent of the budget at which an alert fires"
  type = list(object({
    threshold_percent = number
    spend_basis       = string
  }))
}

variable "disable_default_iam_recipients" {
  type    = bool
  default = false
}
