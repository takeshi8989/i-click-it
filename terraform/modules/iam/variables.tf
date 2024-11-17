variable "aws_region" {
  description = "AWS region for constructing ARNs"
  type        = string
}

variable "aws_account_id" {
  description = "AWS account ID for constructing ARNs"
  type        = string
}

variable "ec2_instance_arn" {
  description = "ARN of the EC2 instance to manage"
  type        = string
}

variable "role_name" {
  description = "Name of the IAM role"
  type        = string
}

variable "policy_name" {
  description = "Name of the IAM policy"
  type        = string
}

variable "instance_profile_name" {
  description = "Name of the IAM instance profile"
  type        = string
}

variable "s3_bucket_arn" {
  description = "ARN of the S3 bucket"
  type        = string
}

variable "cloudwatch_policy_name" {
  description = "Name of the CloudWatch IAM policy"
  type        = string
}

variable "tags" {
  description = "Tags to apply to IAM resources"
  type        = map(string)
}

variable "eventbridge_role_name" {
  description = "Name of the IAM role for EventBridge"
  type        = string
}

variable "eventbridge_policy_name" {
  description = "Name of the IAM policy for EventBridge"
  type        = string
}
