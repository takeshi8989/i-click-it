output "log_group_name" {
  value = aws_cloudwatch_log_group.log_group.name
}

output "start_event_rule_names" {
  value = { for k, v in aws_cloudwatch_event_rule.start_rules : k => v.name }
}

output "stop_event_rule_names" {
  value = { for k, v in aws_cloudwatch_event_rule.stop_rules : k => v.name }
}

output "start_event_rule_arns" {
  value = {
    for key, rule in aws_cloudwatch_event_rule.start_rules : key => rule.arn
  }
}

output "stop_event_rule_arns" {
  value = {
    for key, rule in aws_cloudwatch_event_rule.stop_rules : key => rule.arn
  }
}