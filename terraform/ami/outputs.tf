output "ami_id" {
  description = "The ID of the most recent Ubuntu AMI"
  value       = data.aws_ami.ubuntu.id
}
