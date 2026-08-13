output "arn" {
  value = aws_sfn_state_machine.this.arn
}

output "id" {
  value = aws_sfn_state_machine.this.id
}

output "name" {
  value = aws_sfn_state_machine.this.name
}

output "creation_date" {
  value = aws_sfn_state_machine.this.creation_date
}

output "status" {
  value = aws_sfn_state_machine.this.status
}
