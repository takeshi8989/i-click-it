variable "log_group_name" {
  description = "The name of the CloudWatch log group"
  type        = string
}

variable "retention_in_days" {
  description = "Retention in days for the log group"
  type        = number
  default     = 7
}

variable "class_schedules" {
  description = "List of class schedules with start and stop times"
  type        = list(object({
    classname  = string
    start_time = string
    end_time   = string
  }))
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
