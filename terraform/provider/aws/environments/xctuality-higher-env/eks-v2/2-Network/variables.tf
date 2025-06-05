
variable "region" {
  type = string
}

variable "domain" {
  type = string
}

variable "cidr_block" {
  type = string
}

variable "enable_dns_support" {
  type = bool
}

variable "enable_dns_hostnames" {
  type = bool
}


variable "subnets" {
  type = list(object({
    cidr_block        = string
    availability_zone = string
    type              = string
    subnet_tags       = map(string)
  }))
}

variable "route_tables" {
  type = list(object({
    cidr_block = string
    gateway_id = string
  }))
}


variable "tags" {
  type = map(string)
}
