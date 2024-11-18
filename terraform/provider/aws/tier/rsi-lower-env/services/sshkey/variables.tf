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

variable "env" {
  default = "lower"
}

variable "purpose" {
  default = "apps"
}

variable "cluster_name" {
  type = string
  default = "lower-rsi-infra"
}
