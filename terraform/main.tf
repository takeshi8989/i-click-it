provider "aws" {
  region = "us-east-1"
}

module "iam" {
  source = "./iam"
}

module "security" {
  source = "./security"
}

module "ami" {
  source = "./ami"
}

module "cloudwatch" {
  source = "./cloudwatch"
}

module "instance" {
  source                = "./instance"
  security_group_id     = module.security.security_group_id
  iam_instance_profile  = module.iam.instance_profile_name
  ami_id                = module.ami.ami_id
}
