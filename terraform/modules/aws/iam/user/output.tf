output "id" {
    value = aws_iam_access_key.this.id
}

output "secret" {
    value = aws_iam_access_key.this.encrypted_secret
}