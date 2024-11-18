variable "profile" {
  description = "local aws-cli profile name"
  default     = "rsi-higher"
}

variable "region" {
  description = "aws region"
  default     = "ap-southeast-1"
}

variable "tier" {
  default = "high"
}

variable "env" {
  default = "higher"
}

variable "purpose" {
  default = "apps"
}

variable "cluster_name" {
  type = string
  default = "higher-rsi-infra"
}

variable "cidr" {
  default = "10.0.24.0/22"
}

variable "cidr-priv-1a" {
  default = "10.0.24.0/25"
}

variable "cidr-priv-1b" {
  default = "10.0.24.128/25"
}

variable "cidr-priv-1c" {
  default = "10.0.25.0/25"
}

variable "cidr-pub-1a" {
  default = "10.0.25.128/25"
}

variable "cidr-pub-1b" {
  default = "10.0.26.0/25"
}

variable "cidr-pub-1c" {
  default = "10.0.26.128/25"
}