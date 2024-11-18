output "log_group_name" {
  value = aws_cloudwatch_log_group.log_group.name
}

output "start_event_rule_names" {
  value = { for k, v in aws_cloudwatch_event_rule.start_rules : k => v.name }
}

output "stop_event_rule_names" {
  value = { for k, v in aws_cloudwatch_event_rule.stop_rules : k => v.name }
}

# Output all start rule ARNs as a map
output "start_event_rule_arns" {
  value = {
    for key, rule in aws_cloudwatch_event_rule.start_rules : key => rule.arn
  }
}

# Output all stop rule ARNs as a map
output "stop_event_rule_arns" {
  value = {
    for key, rule in aws_cloudwatch_event_rule.stop_rules : key => rule.arn
  }
}