resource "aws_route_table_association" "this" {

  for_each = {for i, route in var.route_table_associations : i => route}

  subnet_id      = each.value.subnet_id
  route_table_id = each.value.route_table_id
  
}
