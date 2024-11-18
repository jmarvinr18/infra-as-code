variable "admins" {
  default = []
}

variable "developers" {
  default = []
}

variable "tier" {
  default = ""
}

variable "developers_kms_keys" {
  type    = set(string)
  default = []
}
