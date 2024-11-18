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

variable "cidr" {
  default = "10.0.20.0/22"
}

variable "cidr-priv-1a" {
  default = "10.0.20.0/25"
}

variable "cidr-priv-1b" {
  default = "10.0.20.128/25"
}

variable "cidr-priv-1c" {
  default = "10.0.21.0/25"
}

variable "cidr-pub-1a" {
  default = "10.0.21.128/25"
}

variable "cidr-pub-1b" {
  default = "10.0.22.0/25"
}

variable "cidr-pub-1c" {
  default = "10.0.22.128/25"
}