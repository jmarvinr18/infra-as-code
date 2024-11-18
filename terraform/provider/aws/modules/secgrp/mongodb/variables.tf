

variable "vpc_id" {
  type        = string
  description = "vpc id"
}

variable "cidr_list" {
  type        = list(any)
  description = "list of cidr blocks"
}

variable "authorize_remote" {
  type        = list(any)
  description = "authorize ip to remote"
}