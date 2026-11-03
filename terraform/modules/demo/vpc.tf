module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 6.7"

  name = "${local.name_prefix}vpc"

  azs             = ["us-east-1a", "us-east-1b", "us-east-1c"]
  cidr            = var.vpc_cidr
  private_subnets = var.private_subnet_cidrs
  public_subnets  = var.public_subnet_cidrs

  single_nat_gateway = true
  enable_nat_gateway = true
  enable_vpn_gateway = false

  tags = local.default_tags
}

