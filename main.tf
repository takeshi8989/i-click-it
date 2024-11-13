data "aws_caller_identity" "current" {}
data "aws_region" "current" {}
# Provider configuration
provider "aws" {
  region = "us-east-1"  # Change this to your preferred region
}


# S3 bucket for storing the Python script
resource "aws_s3_bucket" "app_bucket" {
  bucket = "my-python-app-bucket"  # Change this to a unique bucket name
}

# Upload main.py to S3 bucket
resource "aws_s3_object" "main_py" {
  bucket = aws_s3_bucket.app_bucket.id
  key    = "main.py"
  source = "main.py"
}

resource "aws_security_group" "allow_ssh" {
  name        = "allow_ssh"
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
    Name = "allow_ssh"
  }
}

resource "aws_cloudwatch_log_group" "app_log_group" {
  name = "/ec2/python-app"
  retention_in_days = 1
}

resource "aws_cloudwatch_log_stream" "log_stream" {
  name           = "my-log-stream"
  log_group_name = aws_cloudwatch_log_group.app_log_group.name
}

resource "aws_iam_role_policy" "cloudwatch_policy" {
  name = "cloudwatch_policy"
  role = aws_iam_role.ec2_s3_access_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "cloudwatch:PutMetricData",
          "ec2:DescribeVolumes",
          "ec2:DescribeTags",
          "logs:PutLogEvents",
          "logs:DescribeLogStreams",
          "logs:DescribeLogGroups",
          "logs:CreateLogStream",
          "logs:CreateLogGroup"
        ]
        Resource = "*"
      }
    ]
  })
}

# EC2 instance
resource "aws_instance" "app_instance" {
  ami           = "ami-06b21ccaeff8cd686"
  instance_type = "t2.micro"

  # IAM instance profile to allow S3 access
  iam_instance_profile = aws_iam_instance_profile.ec2_s3_profile.name
  vpc_security_group_ids = [aws_security_group.allow_ssh.id]
  instance_initiated_shutdown_behavior = "stop"
 
    user_data = <<-EOF
                Content-Type: multipart/mixed; boundary="//"
                MIME-Version: 1.0

                --//
                Content-Type: text/cloud-config; charset="us-ascii"
                MIME-Version: 1.0
                Content-Transfer-Encoding: 7bit
                Content-Disposition: attachment; filename="cloud-config.txt"

                #cloud-config
                cloud_final_modules:
                - [scripts-user, always]

                --//
                Content-Type: text/x-shellscript; charset="us-ascii"
                MIME-Version: 1.0
                Content-Transfer-Encoding: 7bit
                Content-Disposition: attachment; filename="userdata.txt"

                #!/bin/bash
                exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1
                echo "Starting user data script execution"
                
                # Update system and install required packages
                dnf update -y
                dnf install -y amazon-cloudwatch-agent python3-pip unzip wget
                echo "Installed CloudWatch agent and pip3"

                # Install Google Chrome
                dnf install -y https://dl.google.com/linux/chrome/rpm/stable/x86_64/google-chrome-stable-131.0.6778.69-1.x86_64.rpm
                
                # Install ChromeDriver
                echo "Installing ChromeDriver"
                sudo apt-get install unzip
                wget -N https://storage.googleapis.com/chrome-for-testing-public/131.0.6778.69/linux64/chromedriver-linux64.zip -P /home/ec2-user/tmp
                unzip /home/ec2-user/tmp/chromedriver-linux64.zip -d /home/ec2-user/tmp
                mkdir -p /home/ec2-user/bin
                mv /home/ec2-user/tmp/chromedriver-linux64/chromedriver /home/ec2-user/bin
                chmod +x /home/ec2-user/bin/chromedriver
                rm -rf /home/ec2-user/tmp
                echo "Installed ChromeDriver"
                
                # Install additional dependencies
                dnf install -y atk cups-libs gtk3 libXcomposite alsa-lib libXcursor libXdamage libXext libXi libXrandr libXScrnSaver libXtst pango at-spi2-atk libXt xorg-x11-server-Xvfb xorg-x11-xauth dbus-glib dbus-glib-devel
                echo "Installed additional dependencies"

                # Install Python packages in a virtual environment
                python3 -m venv /home/ec2-user/venv
                source /home/ec2-user/venv/bin/activate
                pip install --upgrade pip
                pip install boto3 selenium
                deactivate
                echo "Installed Python packages in virtual environment"
                
                # Configure CloudWatch agent
                cat > /opt/aws/amazon-cloudwatch-agent/bin/config.json << CWCONF
                {
                    "agent": {
                      "metrics_collection_interval": 60,
                      "run_as_user": "root",
                      "logfile": "/opt/aws/amazon-cloudwatch-agent/logs/amazon-cloudwatch-agent.log"
                    },
                    "logs": {
                      "logs_collected": {
                          "files": {
                          "collect_list": [
                              {
                                "file_path": "/home/ec2-user/main.py.log",
                                "log_group_name": "${aws_cloudwatch_log_group.app_log_group.name}",
                                "log_stream_name":  "${aws_cloudwatch_log_stream.log_stream.name}",
                                "timezone": "UTC"
                              }
                          ]
                        }
                      }
                    }
                }
                CWCONF
                echo "Created CloudWatch agent config"
                
                # Start CloudWatch agent
                /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a fetch-config -m ec2 -s -c file:/opt/aws/amazon-cloudwatch-agent/bin/config.json
                echo "Started CloudWatch agent"
                
                # Download main.py from S3
                aws s3 cp s3://${aws_s3_bucket.app_bucket.id}/main.py /home/ec2-user/main.py
                
                # Set correct permissions
                chown -R ec2-user:ec2-user /home/ec2-user
                echo "Copied main.py from S3 and set permissions"
                
                # Run the Python script
                source /home/ec2-user/venv/bin/activate
                python /home/ec2-user/main.py > /home/ec2-user/main.py.log 2>&1 & 
                EOF

  tags = {
    Name = "Python App Instance"
  }
}

# IAM role for EC2 to access S3
resource "aws_iam_role" "ec2_s3_access_role" {
  name = "ec2_s3_access_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

# IAM policy for S3 access
resource "aws_iam_role_policy" "s3_access_policy" {
  name = "s3_access_policy"
  role = aws_iam_role.ec2_s3_access_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "s3:GetObject",
          "s3:ListBucket"
        ]
        Effect = "Allow"
        Resource = [
          aws_s3_bucket.app_bucket.arn,
          "${aws_s3_bucket.app_bucket.arn}/*"
        ]
      }
    ]
  })
}

# IAM instance profile
resource "aws_iam_instance_profile" "ec2_s3_profile" {
  name = "ec2_s3_profile"
  role = aws_iam_role.ec2_s3_access_role.name
}


# CloudWatch Event Rules (UTC)
# PSYC 102
resource "aws_cloudwatch_event_rule" "start_instance_rule" {
  name                = "start_instance_tth"
  description         = "Starts the EC2 instance at 6 PM UTC on Tuesday, Thursday"
  schedule_expression = "cron(0 19 ? * TUE,THU *)"
}

resource "aws_cloudwatch_event_rule" "stop_instance_rule" {
  name                = "stop_instance_tth"
  description         = "Stops the EC2 instance at 7:45 PM UTC on Tuesday, Thursday"
  schedule_expression = "cron(00 21 ? * TUE,THU *)"
}

# CPSC 317 
resource "aws_cloudwatch_event_rule" "start_instance_rule_2" {
  name                = "start_instance_mwf_2"
  description         = "Starts the EC2 instance at 10 PM UTC on Monday, Wednesday, and Friday"
  schedule_expression = "cron(0 23 ? * MON,WED,FRI *)"
}

resource "aws_cloudwatch_event_rule" "stop_instance_rule_2" {
  name                = "stop_instance_mwf_2"
  description         = "Stops the EC2 instance at 11 PM UTC on Monday, Wednesday, and Friday"
  schedule_expression = "cron(00 01 ? * TUE,THU,SAT *)"
}

# Existing CloudWatch Event Targets
resource "aws_cloudwatch_event_target" "start_instance_target" {
  rule      = aws_cloudwatch_event_rule.start_instance_rule.name
  target_id = "StartInstanceLambda"
  arn       = aws_lambda_function.start_ec2_instance.arn
}

resource "aws_cloudwatch_event_target" "stop_instance_target" {
  rule      = aws_cloudwatch_event_rule.stop_instance_rule.name
  target_id = "StopInstanceLambda"
  arn       = aws_lambda_function.stop_ec2_instance.arn
}

# Additional CloudWatch Event Targets for rule2s
resource "aws_cloudwatch_event_target" "start_instance_target_2" {
  rule      = aws_cloudwatch_event_rule.start_instance_rule_2.name
  target_id = "StartInstanceLambda2"
  arn       = aws_lambda_function.start_ec2_instance.arn
}

resource "aws_cloudwatch_event_target" "stop_instance_target_2" {
  rule      = aws_cloudwatch_event_rule.stop_instance_rule_2.name
  target_id = "StopInstanceLambda2"
  arn       = aws_lambda_function.stop_ec2_instance.arn
}

resource "aws_iam_role" "eventbridge_role" {
  name = "eventbridge_start_stop_ec2_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "events.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy" "eventbridge_policy" {
  name = "eventbridge_start_stop_ec2_policy"
  role = aws_iam_role.eventbridge_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ssm:StartAutomationExecution"
        ]
        Resource = [
          "arn:aws:ssm:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:automation-definition/AWS-StartEC2Instance",
          "arn:aws:ssm:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:automation-definition/AWS-StopEC2Instance"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "ec2:StartInstances",
          "ec2:StopInstances"
        ]
        Resource = aws_instance.app_instance.arn
      }
    ]
  })
}


# Lambda functions
resource "aws_lambda_function" "start_ec2_instance" {
  filename      = "lambda_function_start.zip"
  function_name = "start_ec2_instance"
  role          = aws_iam_role.lambda_role.arn
  handler       = "lambda_function_start.lambda_handler"
  runtime       = "python3.8"
  timeout       = 300

  source_code_hash = filebase64sha256("lambda_function_start.zip")

  environment {
    variables = {
      EC2_INSTANCE_ID = aws_instance.app_instance.id
    }
  }
}

resource "aws_lambda_function" "stop_ec2_instance" {
  filename      = "lambda_function_stop.zip"
  function_name = "stop_ec2_instance"
  role          = aws_iam_role.lambda_role.arn
  handler       = "lambda_function_stop.lambda_handler"
  runtime       = "python3.8"
  timeout       = 300
  source_code_hash = filebase64sha256("lambda_function_stop.zip")

  environment {
    variables = {
      EC2_INSTANCE_ID = aws_instance.app_instance.id
    }
  }
}


resource "aws_iam_role" "lambda_role" {
  name = "lambda_start_stop_ec2_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy" "lambda_policy" {
  name = "lambda_start_stop_ec2_policy"
  role = aws_iam_role.lambda_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ec2:StartInstances",
          "ec2:StopInstances",
          "ec2:DescribeInstances"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "arn:aws:logs:*:*:*"
      }
    ]
  })
}

# Lambda Permissions
resource "aws_lambda_permission" "allow_cloudwatch_to_call_start_lambda_1" {
  statement_id  = "AllowExecutionFromCloudWatch1"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.start_ec2_instance.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.start_instance_rule.arn
}

resource "aws_lambda_permission" "allow_cloudwatch_to_call_stop_lambda_1" {
  statement_id  = "AllowExecutionFromCloudWatch2"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.stop_ec2_instance.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.stop_instance_rule.arn
}

resource "aws_lambda_permission" "allow_cloudwatch_to_call_start_lambda_2" {
  statement_id  = "AllowExecutionFromCloudWatch3"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.start_ec2_instance.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.start_instance_rule_2.arn
}

resource "aws_lambda_permission" "allow_cloudwatch_to_call_stop_lambda_2" {
  statement_id  = "AllowExecutionFromCloudWatch4"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.stop_ec2_instance.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.stop_instance_rule_2.arn
}

variable "iclicker_email" {
  type = string
  sensitive = true
}

variable "iclicker_password" {
  type = string
  sensitive = true
}

# Define the email parameter
resource "aws_ssm_parameter" "iclicker_email" {
  name  = "/iclicker/email"
  type  = "SecureString"
  value = var.iclicker_email
  tags = {
    Environment = "production"
  }
}

# Define the password parameter
resource "aws_ssm_parameter" "iclicker_password" {
  name  = "/iclicker/password"
  type  = "SecureString"
  value = var.iclicker_password
  tags = {
    Environment = "production"
  }
}

# IAM policy for SSM access
resource "aws_iam_role_policy" "ssm_access_policy" {
  name = "ssm_access_policy"
  role = aws_iam_role.ec2_s3_access_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ssm:GetParameter",
          "ssm:GetParameters"
        ]
        Resource = [
          "arn:aws:ssm:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:parameter/iclicker/*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "ssm:GetParametersByPath"
        ]
        Resource = [
          "arn:aws:ssm:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:parameter/iclicker/*"
        ]
      }
    ]
  })
}
