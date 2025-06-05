output "ids" {
  value = {
    for k, rt in aws_route_table.this :
    k => rt.id
  }
}
output "arns" {
  value = {
    for k, rt in aws_route_table.this :
    k => rt.arn
  }
}