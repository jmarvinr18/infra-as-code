output "vpc_id" {
  value     = aws_vpc.main.id
  sensitive = false
}