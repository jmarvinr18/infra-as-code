# output "id" {
#   value = aws_subnet.this.id
# }

output "details" {
  value = {
    for k, rt in aws_subnet.this :
    k => rt
  }
}

output "ids" {
  value = {
    for k, rt in aws_subnet.this :
    k => rt.id
  }
}

output "tags" {
  value = {
    for k, rt in aws_subnet.this :
    k => rt.tags
  }
}