variable "security_group_id" {
  description = "The ID of the security group"
  type        = string
}

variable "iam_instance_profile" {
  description = "The name of the IAM instance profile"
  type        = string
}

variable "ami_id" {
  description = "The ID of the AMI to use for the instance"
  type        = string
}
