resource "aws_eip" "nat" {
  domain = "vpc"
  tags   = var.tags
}

resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public-ap-southeast-1a.id

  tags       = var.tags
  depends_on = [aws_internet_gateway.igw]
}