output "cloudwatch_agent_role_arn" {
  value = aws_iam_role.cloudwatch_agent_role.arn
}

output "instance_profile_name" {
  value = aws_iam_instance_profile.cloudwatch_agent_profile.name
}

output "iam_instance_profile" {
  value = aws_iam_instance_profile.cloudwatch_agent_profile.name
}
