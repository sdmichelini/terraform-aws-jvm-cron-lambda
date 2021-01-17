output "function_arn" {
  value       = aws_lambda_function.function.arn
  description = "ARN of the lambda function"
}

output "function_name" {
  value       = aws_lambda_function.function.function_name
  description = "Name of the lambda function"
}