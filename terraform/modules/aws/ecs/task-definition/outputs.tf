output "arn" {
    value = aws_ecs_task_definition.this.arn
    description = "Provides ARN info about the task definition"
}

output "id" {
    value = aws_ecs_task_definition.this.id
    description = "Provides ID info about the task definition"
}