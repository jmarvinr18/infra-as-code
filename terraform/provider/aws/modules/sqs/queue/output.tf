output "id" {
  description = "Queue URL — aws_sqs_queue.id is the URL, not the name."
  value       = aws_sqs_queue.this.id
}

output "url" {
  value = aws_sqs_queue.this.url
}

output "arn" {
  value = aws_sqs_queue.this.arn
}

output "name" {
  value = aws_sqs_queue.this.name
}
