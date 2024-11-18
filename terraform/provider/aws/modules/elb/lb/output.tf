output "arn" {
    value = aws_lb.this.arn
}

output "cname" {
  value = aws_lb.this.dns_name
}

output "id" {
  value = aws_lb.this.id
}

output "name" {
  value = aws_lb.this.name
}