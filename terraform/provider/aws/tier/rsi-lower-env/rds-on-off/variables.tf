
variable "profile" {
  description = "Local AWS CLI profile name"
  default = "rsi-lower"
}

variable "region" {
  description = "EC2 Region for the VPC"
  default     = "ap-southeast-1"
}

variable "env" {
  default = "lower"
}

variable "tier" {
  default = "dta"
}

variable "instance_ids" {
  description = "our target db instance ids"
  type = list(string)
  default = ["postgresql-15-poc"] 
}