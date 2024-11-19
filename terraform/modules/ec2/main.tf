resource "aws_security_group" "allow_ssh" {
  name        = var.security_group_name
  description = "Allow SSH inbound traffic"

  ingress {
    description = "SSH from anywhere"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = var.security_group_name
  }
}

resource "aws_instance" "iclicker_instance" {
  ami           = var.ami
  instance_type = var.instance_type

  iam_instance_profile = var.iam_instance_profile
  vpc_security_group_ids = [aws_security_group.allow_ssh.id]
  instance_initiated_shutdown_behavior = "stop"

  user_data = templatefile("${path.module}/user_data.sh", {
    CHROME_VERSION             = "131.0.6778.69"
    CLOUDWATCH_LOG_GROUP_NAME  = "/ec2/iclicker"
    CLOUDWATCH_LOG_STREAM_NAME = "iclicker_log_stream"
    S3_BUCKET_NAME             = var.s3_bucket_id
  })

  tags = merge({
    Name = var.instance_name
  }, var.tags)
}
