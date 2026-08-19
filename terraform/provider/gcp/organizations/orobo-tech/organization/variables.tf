variable "org_id" {
  description = "orobo-tech organization id"
  type        = string
}

variable "billing_account" {
  description = "Billing account to link the projects to. Empty leaves them unlinked."
  type        = string
}

variable "app" {
  type = string
}

variable "envs" {
  type = list(string)
}

variable "purpose" {
  type = string
}

variable "region" {
  type = string
}

variable "deletion_policy" {
  type = string
}

variable "services" {
  type = list(string)
}
