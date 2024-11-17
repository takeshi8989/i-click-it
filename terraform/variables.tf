variable "aws_region" {
  description = "The AWS region to deploy resources in"
  type        = string
  default     = "us-east-1"
}

variable "iclicker_email" {
  type      = string
  sensitive = true
}

variable "iclicker_password" {
  type      = string
  sensitive = true
}

variable "tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default     = {
    Environment = "dev"
    Project     = "iclicker"
  }
}