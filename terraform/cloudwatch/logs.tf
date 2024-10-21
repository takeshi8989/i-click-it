resource "aws_cloudwatch_log_group" "iclicker_log_group" {
  name              = "/aws/ec2/iclicker"
  retention_in_days = 7  # Logs will be retained for 7 days
}
