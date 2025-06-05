resource "aws_route_table" "this" {
  for_each = { for i, route in var.route_tables : i => route }
  vpc_id = var.vpc_id

  route {
    cidr_block     = each.value.cidr_block
    gateway_id = each.value.gateway_id
  }

  tags = merge(each.value.zone_tag, var.tags)
}