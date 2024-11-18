
variable "cidr" {
  type = string
}

variable "tags" {
  default = {}
}

variable "cidr-priv-1a" {
  type = string
}

variable "cidr-priv-1b" {
  type = string
}

variable "cidr-priv-1c" {
  type = string
}

variable "cidr-pub-1a" {
  type = string
}

variable "cidr-pub-1b" {
  type = string
}

variable "cidr-pub-1c" {
  type = string
}

variable "cluster_name" {
  type = string
}

variable "elb_subnet_state" {
  type = string
}