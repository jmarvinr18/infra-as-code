
variable "vpc_id" {
  type = string
}


variable "subnets" {
  type = list(object({
      cidr_block = string
      availability_zone = string
      type = string
      subnet_tags = map(string)
  }))
}

variable "tags" {
  type = map(string)
}
