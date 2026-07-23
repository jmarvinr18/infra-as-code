variable "vpc_cidr_block" {
  type = string
}

variable "enable_dns_support" {
  type = bool
}

variable "enable_dns_hostnames" {
  type = bool
}


variable "tags" {
  type = map(string)
}

variable "public" {
  type = string
}

variable "private" {
  type = string
}

variable "zones" {
  type = list(string)
}

variable "zone_cidr_block" {
  type = object({
    private_zone_1 = string,
    private_zone_2 = string,
    public_zone1   = string,
    public_zone2   = string
  })
}

variable "map_public_ip_on_launch" {
  type = bool
}


variable "aws_eip_domain" {
  type = string
}

variable "route_table_cidr_block" {
  type = string
}