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

output "tags" {
  value = {
    for k, rt in aws_route_table.this :
    k => rt.tags
  }
}

output "details" {
  value = {
    for k, rt in aws_route_table.this :
    k => rt
  }
}