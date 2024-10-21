variable "create_security_group" {
  description = "Whether to create a new security group or use an existing one"
  type        = bool
  default     = true
}

variable "vpc_id" {
  description = "The VPC ID where the security group should be created or looked up"
  type        = string
}
