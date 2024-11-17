variable "bucket_name" {
  description = "Base name for the S3 bucket"
  type        = string
  default     = "iclicker"
}

variable "account_id" {
  description = "The AWS account ID"
  type        = string
}