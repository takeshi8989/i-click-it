resource "aws_instance" "iclicker_instance" {
  ami                    = var.ami_id
  instance_type          = "t2.micro"
  vpc_security_group_ids = [var.security_group_id]
  iam_instance_profile   = var.iam_instance_profile
  
  tags = {
    Name = "IClickerInstance"
  }

  user_data = file("${path.module}/user_data.sh")
}
