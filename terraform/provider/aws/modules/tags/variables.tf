variable "tier" {
  type        = string
  description = "Tier of resource: prod or non-prod"
  default     = "non-prod"
}

variable "env" {
  type        = string
  description = "Environment that this is running in."
  default     = ""
}

variable "purpose" {
  type        = string
  description = "Purpose of the resource."
  default     = ""
}

variable "region" {
  type    = string
  default = ""
}

# Defaults
variable "provisioner" {
  type        = string
  description = "The provisioner of the resource (default: terraform)"
  default     = "terraform"
}

variable "additional" {
  default = {}
}

variable "name" {
  default = ""
}
