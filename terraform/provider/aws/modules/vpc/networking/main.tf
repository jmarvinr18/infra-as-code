
resource "aws_vpc" "this" {
  cidr_block = var.cidr

  instance_tenancy = "default"

  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = var.tags
}

resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id
  tags   = var.tags
}