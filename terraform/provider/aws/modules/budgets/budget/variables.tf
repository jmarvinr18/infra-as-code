variable "budget_name" {
  type    = string
}

variable "monthly_limit" {
  description = "Monthly cost limit in USD"
  type        = number
}

variable "budget_type" {
  type = string
}

variable "limit_unit" {
  type = string
}

variable "time_unit" {
  type = string
}

variable "notifications" {
    type = list(object({
      comparison_operator = string
      threshold = number
      threshold_type = string
      notification_type = string
      subscriber_email_addresses = list(string)
  }))

}
