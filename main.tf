provider "aws" {
  region = "ap-southeast-2"
  shared_credentials_file = "~/.aws/config"
  profile = "customprofile"
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "2.21.0"

  name = var.vpc_name
  cidr = var.vpc_cidr

  azs             = var.vpc_azs
  private_subnets = var.vpc_private_subnets
  public_subnets  = var.vpc_public_subnets

  enable_nat_gateway = var.vpc_enable_nat_gateway

  tags = var.vpc_tags
}

module "ec2_instances" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "2.12.0"

  name           = "my-ec2-cluster"
  instance_count = 1

  ami                    = "ami-05c029a4b57edda9e"
  instance_type          = "t2.micro"
  vpc_security_group_ids = [module.vpc.default_security_group_id]
  subnet_id              = module.vpc.public_subnets[0]

  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}

module "website_s3_bucket" {
  source = "./modules/aws-s3-static-website-bucket"

  bucket_name = "julie-test-2021-11"

  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}