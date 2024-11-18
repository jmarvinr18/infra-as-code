
resource "aws_vpc" "main" {
  cidr_block = var.cidr

  instance_tenancy = "default"

  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = var.tags
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
  tags   = var.tags
}


