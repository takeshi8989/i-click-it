output "instance_id" {
  value = aws_instance.iclicker_instance.id
}

output "instance_arn" {
  value = aws_instance.iclicker_instance.arn
}

output "security_group_id" {
  value = aws_security_group.allow_ssh.id
}
