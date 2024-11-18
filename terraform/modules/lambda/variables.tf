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

variable "start_event_rule_arns" {
  description = "Map of ARNs for CloudWatch start event rules"
  type        = map(string)
}

variable "stop_event_rule_arns" {
  description = "Map of ARNs for CloudWatch stop event rules"
  type        = map(string)
}
