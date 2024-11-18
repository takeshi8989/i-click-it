# CloudWatch Log Group
resource "aws_cloudwatch_log_group" "log_group" {
  name              = var.log_group_name
  retention_in_days = var.retention_in_days

  tags = var.tags
}

# Iterate over each class schedule to create start and stop rules
resource "aws_cloudwatch_event_rule" "start_rules" {
  for_each            = { for schedule in var.class_schedules : schedule.classname => schedule }
  name                = "start_rule_${each.key}"
  description         = "Start rule for ${each.value.classname}"
  schedule_expression = each.value.start_time
}

resource "aws_cloudwatch_event_rule" "stop_rules" {
  for_each            = { for schedule in var.class_schedules : schedule.classname => schedule }
  name                = "stop_rule_${each.key}"
  description         = "Stop rule for ${each.value.classname}"
  schedule_expression = each.value.end_time
}

# Event Targets for Start Rules
resource "aws_cloudwatch_event_target" "start_targets" {
  for_each = aws_cloudwatch_event_rule.start_rules
  rule      = each.value.name
  target_id = "StartInstanceLambda_${each.key}"
  arn       = var.start_lambda_function_arn
}

# Event Targets for Stop Rules
resource "aws_cloudwatch_event_target" "stop_targets" {
  for_each = aws_cloudwatch_event_rule.stop_rules
  rule      = each.value.name
  target_id = "StopInstanceLambda_${each.key}"
  arn       = var.stop_lambda_function_arn
}
