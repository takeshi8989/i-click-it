output "role_name" {
  value = aws_iam_role.ec2_s3_access_role.name
}

output "instance_profile_name" {
  value = aws_iam_instance_profile.ec2_s3_profile.name
}

output "eventbridge_role_name" {
  value = aws_iam_role.eventbridge_role.name
}

output "eventbridge_policy_name" {
  value = aws_iam_role_policy.eventbridge_policy.name
}
