output "key_name" {
  value = aws_key_pair.rsa.key_name
}

output "private_key" {
  sensitive = true
  value     = tls_private_key.rsa.private_key_pem
}

output "public_key" {
  value = tls_private_key.rsa.public_key_openssh
  sensitive = true
}