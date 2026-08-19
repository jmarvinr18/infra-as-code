variable "env" {
  type        = string
  description = "Environment that this is running in: prod, staging or shared"
  default     = ""
}

variable "app" {
  type        = string
  description = "Application that owns the resource."
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
