variable "budget_name" {
  type    = string
}

variable "monthly_limit" {
  description = "Monthly cost limit in USD"
  type        = number
}

variable "environment"{ 
    type = string 
}

variable "region" { 
    type = string
    default = "ap-southeast-1"
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

variable "client"{ 
    type = string 
}

variable "client_account_id" {
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
