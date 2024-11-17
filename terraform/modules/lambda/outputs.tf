output "start_lambda_function_arn" {
  value = aws_lambda_function.start_instance.arn
}

output "stop_lambda_function_arn" {
  value = aws_lambda_function.stop_instance.arn
}
