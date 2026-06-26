
variable "description" {
  type = string
}

variable "enable_key_rotation" {
  type = bool
  default = true
}

variable "deletion_window_in_days" {
  type = number
}

variable "policy" {
  type = string
}

variable "tags" {
  type = map(string)
}

variable "kms_alias_name" {
  type = string
}