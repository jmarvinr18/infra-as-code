data "aws_vpc" "selected" {
  tags = {
    Env  = var.env
    Tier = var.tier
  }
}

data "aws_subnets" "private" {
  filter {
    name   = "tag:kubernetes.io/role/internal-elb"
    values = ["1"]
  }
}

data "aws_subnets" "public" {
  filter {
    name   = "tag:kubernetes.io/role/elb"
    values = ["1"]
  }
}

data "aws_subnets" "public_default" {
  filter {
    name   = "tag:Env"
    values = ["lower"]
  }
}

data "aws_subnet" "subnets_az" {
  for_each = toset(concat(data.aws_subnets.public.ids, data.aws_subnets.private.ids))
  id       = each.key
}