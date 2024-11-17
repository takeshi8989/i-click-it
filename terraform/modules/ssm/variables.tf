variable "iclicker_email" {
  description = "The iClicker email address"
  type        = string
  sensitive   = true
}

variable "iclicker_password" {
  description = "The iClicker password"
  type        = string
  sensitive   = true
}

variable "tags" {
  description = "Tags to apply to all SSM resources"
  type        = map(string)
}
