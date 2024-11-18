
variable "profile" {
  description = "Local AWS CLI profile name"
  default = "rsi-higher"
}

variable "region" {
  description = "EC2 Region for the VPC"
  default     = "ap-southeast-1"
}

variable "env" {
  default = "higher"
}

variable "tier" {
  default = "high"
}

variable "instance_ids" {
  description = "our target db instance ids"
  type = list(string)
  default = ["postgresql-15-poc"] 
}