
####################################################
###                     VPC                      ###
####################################################

resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr_block

  enable_dns_support   = var.enable_dns_support
  enable_dns_hostnames = var.enable_dns_hostnames

  tags = var.tags
}


####################################################
###                 INTERNET GATEWAY             ###
####################################################

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = var.tags

}

####################################################
###                     SUBNETS                  ###
####################################################


#### private =======================================

resource "aws_subnet" "private_zone1" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.zone_cidr_block.private_zone_1
  availability_zone = var.zones[0]

  tags = merge(
    var.tags,
    {
      "Tier" = var.private
    }
  )
}


resource "aws_subnet" "private_zone2" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.zone_cidr_block.private_zone_2
  availability_zone = var.zones[1]

  tags = merge(
    var.tags,
    {
      "Tier" = var.private
    }
  )
  
}

#### public =======================================

resource "aws_subnet" "public_zone1" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.zone_cidr_block.public_zone1
  availability_zone       = var.zones[0]
  map_public_ip_on_launch = var.map_public_ip_on_launch

  tags = merge(
    var.tags,
    {
      "Tier" = var.public
    }
  )
}

resource "aws_subnet" "public_zone2" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.zone_cidr_block.public_zone2
  availability_zone       = var.zones[1]
  map_public_ip_on_launch = var.map_public_ip_on_launch

  tags = merge(
    var.tags,
    {
      "Tier" = var.public
    }
  )
}




####################################################
###                     NAT                      ###
####################################################

resource "aws_eip" "nat" {
  domain = var.aws_eip_domain

  tags = var.tags

}

resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public_zone1.id

  tags = var.tags

  depends_on = [aws_internet_gateway.igw]
}


####################################################
###                 ROUTE TABLE                  ###
####################################################


resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = var.route_table_cidr_block
    nat_gateway_id = aws_nat_gateway.nat.id
  }

  tags = var.tags
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = var.tags
}

resource "aws_route_table_association" "private_zone1" {
  subnet_id      = aws_subnet.private_zone1.id
  route_table_id = aws_route_table.private.id

  depends_on = [aws_route_table.private]
}

resource "aws_route_table_association" "private_zone2" {
  subnet_id      = aws_subnet.private_zone2.id
  route_table_id = aws_route_table.private.id

  depends_on = [aws_route_table.private]
}

resource "aws_route_table_association" "public_zone1" {
  subnet_id      = aws_subnet.public_zone1.id
  route_table_id = aws_route_table.public.id

  depends_on = [aws_route_table.public]
}

resource "aws_route_table_association" "public_zone2" {
  subnet_id      = aws_subnet.public_zone2.id
  route_table_id = aws_route_table.public.id

  depends_on = [aws_route_table.public]
}


