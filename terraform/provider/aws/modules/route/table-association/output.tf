# output "id" {
#   value = aws_route_table_association.this.id
# }

# output "gateway_id" {
#   value = aws_route_table_association.this.gateway_id
# }

# output "route_table_id" {
#   value = aws_route_table_association.this.route_table_id
# }

# output "subnet_id" {
#   value = aws_route_table_association.this.subnet_id
# }

# output "ids" {
#   value = {
#     for k, rt in aws_route_table_association.this :
#     k => rt.id
#   }
# }
# output "arns" {
#   value = {
#     for k, rt in aws_route_table_association.this :
#     k => rt.ar
#   }
# }