variable "ami" {
  description = "AMI ID for the EC2 instance"
  type        = string
  default     = "ami-06b21ccaeff8cd686"
}

variable "instance_type" {
  description = "Instance type for the EC2 instance"
  type        = string
  default    = "t2.micro"
}

variable "iam_instance_profile" {
  description = "IAM instance profile name"
  type        = string
}

variable "security_group_name" {
  description = "Name of the security group"
  type        = string
  default     = "allow_ssh"
}

variable "instance_name" {
  description = "Name tag for the EC2 instance"
  type        = string
  default     = "iclicker_instance"
}

variable "s3_bucket_id" {
  description = "ID of the S3 bucket"
  type        = string
}

variable "tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
}