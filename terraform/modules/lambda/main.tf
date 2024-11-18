# IAM Role for Lambda
resource "aws_iam_role" "lambda_role" {
  name = var.lambda_role_name

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

# IAM Policy for Lambda
resource "aws_iam_role_policy" "lambda_policy" {
  name = var.lambda_policy_name
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
        Resource = var.ec2_instance_arn
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

# Lambda Function to Start EC2 Instances
resource "aws_lambda_function" "start_instance" {
  filename         = var.start_lambda_zip
  function_name    = var.start_function_name
  role             = aws_iam_role.lambda_role.arn
  handler          = "lambda_function_start.lambda_handler"
  runtime          = var.lambda_runtime
  source_code_hash = filebase64sha256(var.start_lambda_zip)

  environment {
    variables = {
      EC2_INSTANCE_ID = var.ec2_instance_id
    }
  }
}

# Lambda Function to Stop EC2 Instances
resource "aws_lambda_function" "stop_instance" {
  filename         = var.stop_lambda_zip
  function_name    = var.stop_function_name
  role             = aws_iam_role.lambda_role.arn
  handler          = "lambda_function_stop.lambda_handler"
  runtime          = var.lambda_runtime
  source_code_hash = filebase64sha256(var.stop_lambda_zip)

  environment {
    variables = {
      EC2_INSTANCE_ID = var.ec2_instance_id
    }
  }
}

# Lambda Permissions for CloudWatch to call Start Lambda
resource "aws_lambda_permission" "allow_cloudwatch_to_call_start_lambda_1" {
  statement_id  = "AllowExecutionFromCloudWatch1"
  action        = "lambda:InvokeFunction"
  function_name = var.start_lambda_function_name
  principal     = "events.amazonaws.com"
  source_arn    = var.start_event_rule_arn_1
}

resource "aws_lambda_permission" "allow_cloudwatch_to_call_stop_lambda_1" {
  statement_id  = "AllowExecutionFromCloudWatch2"
  action        = "lambda:InvokeFunction"
  function_name = var.stop_lambda_function_name
  principal     = "events.amazonaws.com"
  source_arn    = var.stop_event_rule_arn_1
}

resource "aws_lambda_permission" "allow_cloudwatch_to_call_start_lambda_2" {
  statement_id  = "AllowExecutionFromCloudWatch3"
  action        = "lambda:InvokeFunction"
  function_name = var.start_lambda_function_name
  principal     = "events.amazonaws.com"
  source_arn    = var.start_event_rule_arn_2
}

resource "aws_lambda_permission" "allow_cloudwatch_to_call_stop_lambda_2" {
  statement_id  = "AllowExecutionFromCloudWatch4"
  action        = "lambda:InvokeFunction"
  function_name = var.stop_lambda_function_name
  principal     = "events.amazonaws.com"
  source_arn    = var.stop_event_rule_arn_2
}