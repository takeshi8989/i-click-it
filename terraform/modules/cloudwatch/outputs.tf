output "log_group_name" {
  value = aws_cloudwatch_log_group.log_group.name
}

output "start_event_rule_names" {
  value = [
    aws_cloudwatch_event_rule.start_rule_psyc102.name,
    aws_cloudwatch_event_rule.start_rule_cpsc317.name
  ]
}

output "stop_event_rule_names" {
  value = [
    aws_cloudwatch_event_rule.stop_rule_psyc102.name,
    aws_cloudwatch_event_rule.stop_rule_cpsc317.name
  ]
}

output "start_event_rule_arn_1" {
  value = aws_cloudwatch_event_rule.start_rule_psyc102.arn
}

output "stop_event_rule_arn_1" {
  value = aws_cloudwatch_event_rule.stop_rule_psyc102.arn
}

output "start_event_rule_arn_2" {
  value = aws_cloudwatch_event_rule.start_rule_cpsc317.arn
}

output "stop_event_rule_arn_2" {
  value = aws_cloudwatch_event_rule.stop_rule_cpsc317.arn
}