# output "id" {
#   value = aws_subnet.this.id
# }

output "ids" {
  value = {
    for k, rt in aws_subnet.this :
    k => rt.id
  }
}