terraform {
  required_version = "~> 1.13"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
    archive = {
      source  = "hashicorp/archive"
      version = "~> 2.4"
    }
  }

  #backend "s3" {}
}

provider "aws" {
  region = var.region
  default_tags {
    tags = local.default_tags
  }
}
