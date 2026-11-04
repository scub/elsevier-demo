data "aws_caller_identity" "current" {}

variable "environment" {
  type    = string
  default = "dev"
}

variable "region" {
  type    = string
  default = "us-east-1"
}

variable "vpc_cidr" {
  type    = string
  default = "10.0.0.0/16"
}

variable "personal_ip" {
  type = string
}

variable "alerting_email" {
  type = string
}

variable "state_bucket" {
  type    = string
  default = "tfstate"
}

variable "public_subnet_cidrs" {
  type    = list(string)
  default = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]
}

variable "private_subnet_cidrs" {
  type    = list(string)
  default = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
}

variable "base_tags" {
  type = map(string)
  default = {
    "managed-by" = "terraform"
    "project"    = "demo"
    "scope"      = "elsevier"
    "source"     = "https://github.com/scub/elsevier-demo/"
    "user"       = "penny"
  }
}

locals {
  name_prefix = "${substr(var.environment, 0, 1)}_"

  default_tags = merge(
    var.base_tags,
    {
      "env" = var.environment
    }
  )
}