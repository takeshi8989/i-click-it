variable "log_group_name" {
  description = "The name of the CloudWatch log group"
  type        = string
}

variable "retention_in_days" {
  description = "Retention in days for the log group"
  type        = number
  default     = 7
}

variable "start_schedule_psyc102" {
  description = "Schedule expression for starting EC2 for PSYC 102"
  type        = string
}

variable "stop_schedule_psyc102" {
  description = "Schedule expression for stopping EC2 for PSYC 102"
  type        = string
}

variable "start_schedule_cpsc317" {
  description = "Schedule expression for starting EC2 for CPSC 317"
  type        = string
}

variable "stop_schedule_cpsc317" {
  description = "Schedule expression for stopping EC2 for CPSC 317"
  type        = string
}

variable "start_lambda_function_arn" {
  description = "ARN of the Lambda function to start EC2 instances"
  type        = string
}

variable "stop_lambda_function_arn" {
  description = "ARN of the Lambda function to stop EC2 instances"
  type        = string
}

variable "tags" {
  description = "Tags to apply to CloudWatch resources"
  type        = map(string)
}
