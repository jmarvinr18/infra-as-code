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