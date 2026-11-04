terraform {
  required_version = "~> 1.13"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.71"
    }
    archive = {
      source  = "hashicorp/archive"
      version = "~> 2.8"
    }
  }

  #  backend "s3" {
  #    bucket = ""
  #    key = "${var.environment}_${var.region}/terraform.tfstate"
  #  }
}

provider "aws" {
  region = var.region
  default_tags {
    tags = local.default_tags
  }
}
