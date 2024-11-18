variable "profile" {
  description = "local aws-cli profile name"
  default     = "rsi-lower"
}

variable "region" {
  description = "aws region"
  default     = "ap-southeast-1"
}

variable "tier" {
  default = "dta"
}

variable "admins" {
  type = set(string)
  default = [
    "drey.millena",
    "marvin.ramoda"
  ]
}

variable "developers" {
  type = set(string)
  default = [
    "jimboy.balan",
  ]
}

variable "developers_kms_keys" {
  type = list(any)
  default = [
    "sops"
  ]
}
