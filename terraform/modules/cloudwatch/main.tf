# CloudWatch Log Group
resource "aws_cloudwatch_log_group" "log_group" {
  name              = var.log_group_name
  retention_in_days = var.retention_in_days

  tags = var.tags
}

# CloudWatch Event Rules for Starting and Stopping EC2 Instances
resource "aws_cloudwatch_event_rule" "start_rule_psyc102" {
  name                = "start_instance_psyc102"
  description         = "Starts the EC2 instance at 6 PM UTC on Tuesday, Thursday"
  schedule_expression = var.start_schedule_psyc102
}

resource "aws_cloudwatch_event_rule" "stop_rule_psyc102" {
  name                = "stop_instance_psyc102"
  description         = "Stops the EC2 instance at 8 PM UTC on Tuesday, Thursday"
  schedule_expression = var.stop_schedule_psyc102
}

resource "aws_cloudwatch_event_rule" "start_rule_cpsc317" {
  name                = "start_instance_cpsc317"
  description         = "Starts the EC2 instance at 10 PM UTC on Monday, Wednesday, and Friday"
  schedule_expression = var.start_schedule_cpsc317
}

resource "aws_cloudwatch_event_rule" "stop_rule_cpsc317" {
  name                = "stop_instance_cpsc317"
  description         = "Stops the EC2 instance at 12 PM UTC on Monday, Wednesday, and Friday"
  schedule_expression = var.stop_schedule_cpsc317
}

# CloudWatch Event Targets
resource "aws_cloudwatch_event_target" "start_target_psyc102" {
  rule      = aws_cloudwatch_event_rule.start_rule_psyc102.name
  target_id = "StartInstanceLambda"
  arn       = var.start_lambda_function_arn
}

resource "aws_cloudwatch_event_target" "stop_target_psyc102" {
  rule      = aws_cloudwatch_event_rule.stop_rule_psyc102.name
  target_id = "StopInstanceLambda"
  arn       = var.stop_lambda_function_arn
}

resource "aws_cloudwatch_event_target" "start_target_cpsc317" {
  rule      = aws_cloudwatch_event_rule.start_rule_cpsc317.name
  target_id = "StartInstanceLambda2"
  arn       = var.start_lambda_function_arn
}

resource "aws_cloudwatch_event_target" "stop_target_cpsc317" {
  rule      = aws_cloudwatch_event_rule.stop_rule_cpsc317.name
  target_id = "StopInstanceLambda2"
  arn       = var.stop_lambda_function_arn
}
