variable "name" {
  type = string
}

variable "role_arn" {
  type = string
}

variable "definition" {
  type = string
}

variable "type" {
  type    = string
  default = "STANDARD"

  validation {
    condition     = contains(["STANDARD", "EXPRESS"], var.type)
    error_message = "type must be STANDARD or EXPRESS."
  }
}

variable "logging_configuration" {
  type = object({
    log_destination        = string
    include_execution_data = bool
    level                  = string
  })
  default = null
}

variable "tags" {
  type    = map(string)
  default = {}
}
