# output "arn" {
#   value = aws_organizations_account.this
# }

# output "email" {
#   value = aws_organizations_account.this[0].email
# }

# output "id" {
#   value = aws_organizations_account.this[0].id
# }

output "status" {
  value = aws_organizations_account.this
}