
data "aws_subnets" "public_zone_1" {
  filter {
    name   = "tag:Name"
    values = ["staging-public-ap-southeast-1a"]
  }
}

data "aws_subnets" "public_zone_2" {
  filter {
    name   = "tag:Name"
    values = ["staging-public-ap-southeast-1b"]
  }
}

data "aws_subnets" "private_zone_1" {
  
  filter {
    name   = "tag:Name"
    values = ["staging-private-ap-southeast-1a"]
  }
}

data "aws_subnets" "private_zone_2" {
  filter {
    name   = "tag:Name"
    values = ["staging-private-ap-southeast-1b"]
  }
}

data "aws_route_tables" "private" {
  
  filter {
    name   = "tag:Zone"
    values = ["private"]
  }

}

data "aws_route_tables" "public" {
  filter {
    name   = "tag:Zone"
    values = ["public"]
  }
}