
output "arn" {
  value = data.aws_lambda_function.lambda.arn
}

output "function_name" {
  value = data.aws_lambda_function.lambda.function_name
}