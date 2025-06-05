
variable "vpc_id" {
  type = string
}


variable "subnets" {
  type = list(object({
      cidr_block = string
      availability_zone = string
      type = map(string)
  }))
}