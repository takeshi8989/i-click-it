data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

provider "aws" {
  region = var.aws_region
}


module "s3" {
  source = "./modules/s3"
  account_id  = data.aws_caller_identity.current.account_id
}

module "ec2" {
  source              = "./modules/ec2"
  iam_instance_profile = module.iam.instance_profile_name
  s3_bucket_id       = module.s3.bucket_id
  tags                = var.tags
}

module "ssm" {
  source          = "./modules/ssm"
  iclicker_email  = var.iclicker_email
  iclicker_password = var.iclicker_password
  tags            = var.tags
}

module "iam" {
  source                 = "./modules/iam"
  aws_region             = data.aws_region.current.name
  aws_account_id         = data.aws_caller_identity.current.account_id
  role_name              = "ec2_s3_access_role"
  policy_name            = "s3_access_policy"
  cloudwatch_policy_name = "cloudwatch_policy"
  eventbridge_role_name  = "eventbridge_start_stop_ec2_role"
  eventbridge_policy_name = "eventbridge_start_stop_ec2_policy"
  instance_profile_name  = "ec2_s3_profile"
  s3_bucket_arn          = module.s3.bucket_arn
  ec2_instance_arn       = module.ec2.instance_arn
  tags                   = var.tags
}

module "cloudwatch" {
  source                      = "./modules/cloudwatch"
  log_group_name             = "/ec2/iclicker"
  retention_in_days          = 7
  start_schedule_psyc102      = "cron(0 19 ? * TUE,THU *)"
  stop_schedule_psyc102       = "cron(00 21 ? * TUE,THU *)"
  start_schedule_cpsc317      = "cron(0 23 ? * MON,WED,FRI *)"
  stop_schedule_cpsc317       = "cron(00 01 ? * TUE,THU,SAT *)"
  start_lambda_function_arn   = module.lambda.start_lambda_function_arn
  stop_lambda_function_arn    = module.lambda.stop_lambda_function_arn
  tags                       = var.tags
}

module "lambda" {
  source             = "./modules/lambda"
  lambda_role_name   = "lambda_start_stop_ec2_role"
  lambda_policy_name = "lambda_start_stop_ec2_policy"
  start_lambda_zip   = "${path.root}/../lambda_zips/lambda_function_start.zip"
  stop_lambda_zip    = "${path.root}/../lambda_zips/lambda_function_stop.zip"
  start_function_name = "start_ec2_instance"
  stop_function_name  = "stop_ec2_instance"
  ec2_instance_id    = module.ec2.instance_id
  ec2_instance_arn   = module.ec2.instance_arn
  start_lambda_function_name = "start_ec2_instance"
  stop_lambda_function_name  = "stop_ec2_instance"
  start_event_rule_arn_1     = module.cloudwatch.start_event_rule_arn_1
  stop_event_rule_arn_1      = module.cloudwatch.stop_event_rule_arn_1
  start_event_rule_arn_2     = module.cloudwatch.start_event_rule_arn_2
  stop_event_rule_arn_2      = module.cloudwatch.stop_event_rule_arn_2
}
