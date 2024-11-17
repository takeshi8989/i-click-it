variable "lambda_role_name" {
  description = "The name of the Lambda IAM role"
  type        = string
}

variable "lambda_policy_name" {
  description = "The name of the Lambda IAM policy"
  type        = string
}

variable "start_lambda_zip" {
  description = "The path to the ZIP file for the Start Lambda function"
  type        = string
}

variable "stop_lambda_zip" {
  description = "The path to the ZIP file for the Stop Lambda function"
  type        = string
}

variable "start_function_name" {
  description = "Name of the Start Lambda function"
  type        = string
}

variable "stop_function_name" {
  description = "Name of the Stop Lambda function"
  type        = string
}

variable "lambda_runtime" {
  description = "Runtime for the Lambda functions"
  type        = string
  default     = "python3.8"
}

variable "ec2_instance_id" {
  description = "ID of the EC2 instance to manage"
  type        = string
}

variable "ec2_instance_arn" {
  description = "ARN of the EC2 instance to manage"
  type        = string
}

variable "start_lambda_function_name" {
  description = "Name of the Lambda function to start EC2 instances"
  type        = string
}

variable "stop_lambda_function_name" {
  description = "Name of the Lambda function to stop EC2 instances"
  type        = string
}

variable "start_event_rule_arn_1" {
  description = "ARN of the first CloudWatch start event rule"
  type        = string
}

variable "stop_event_rule_arn_1" {
  description = "ARN of the first CloudWatch stop event rule"
  type        = string
}

variable "start_event_rule_arn_2" {
  description = "ARN of the second CloudWatch start event rule"
  type        = string
}

variable "stop_event_rule_arn_2" {
  description = "ARN of the second CloudWatch stop event rule"
  type        = string
}
