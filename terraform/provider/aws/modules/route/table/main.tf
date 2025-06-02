resource "aws_subnet" "this" {

  for_each = {for i, subnet in var.subnets : i => subnet}

  vpc_id            = var.vpc_id
  cidr_block        = each.value.cidr_block
  availability_zone = each.value.availability_zone

  tags = each.value.tags
  
}