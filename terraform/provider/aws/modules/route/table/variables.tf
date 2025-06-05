
variable "vpc_id" {
  type = string
}


variable "tags" {
  type = map(string)
}

variable "route_tables" {
  type = list(object({
    cidr_block = string
    gateway_id = string
    zone_tag = map(string)
  }))
}