# Define the email parameter
resource "aws_ssm_parameter" "iclicker_email" {
  name  = "/iclicker/email"
  type  = "SecureString"
  value = var.iclicker_email
  tags = var.tags
}

# Define the password parameter
resource "aws_ssm_parameter" "iclicker_password" {
  name  = "/iclicker/password"
  type  = "SecureString"
  value = var.iclicker_password
  tags = var.tags
}
