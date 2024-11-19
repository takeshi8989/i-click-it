resource "aws_iam_role" "ec2_s3_access_role" {
  name = var.role_name

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

  tags = var.tags
}

resource "aws_iam_role_policy" "s3_access_policy" {
  name = var.policy_name
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
          var.s3_bucket_arn,
          "${var.s3_bucket_arn}/*"
        ]
      }
    ]
  })
}

resource "aws_iam_instance_profile" "ec2_s3_profile" {
  name = var.instance_profile_name
  role = aws_iam_role.ec2_s3_access_role.name
}


resource "aws_iam_role_policy" "cloudwatch_policy" {
  name = var.cloudwatch_policy_name
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

resource "aws_iam_role" "eventbridge_role" {
  name = var.eventbridge_role_name

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

  tags = var.tags
}

resource "aws_iam_role_policy" "eventbridge_policy" {
  name = var.eventbridge_policy_name
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
          "arn:aws:ssm:${var.aws_region}:${var.aws_account_id}:automation-definition/AWS-StartEC2Instance",
          "arn:aws:ssm:${var.aws_region}:${var.aws_account_id}:automation-definition/AWS-StopEC2Instance"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "ec2:StartInstances",
          "ec2:StopInstances"
        ]
        Resource = var.ec2_instance_arn
      }
    ]
  })
}

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
          "arn:aws:ssm:${var.aws_region}:${var.aws_account_id}:parameter/iclicker/*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "ssm:GetParametersByPath"
        ]
        Resource = [
          "arn:aws:ssm:${var.aws_region}:${var.aws_account_id}:parameter/iclicker/*"
        ]
      }
    ]
  })
}
