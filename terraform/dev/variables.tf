variable "alerting_email" {
  type        = string
  description = "This email is used for cloudwatch alerts through an SNS subscription"
}

variable "personal_ip" {
  type        = string
  description = "This IP is attached to the Bastion hosts security groups"
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

variable "region" {
  type        = string
  default     = "us-east-1"
  description = "What region are we deploying into"
}

variable "environment" {
  type        = string
  description = "This environment is attached to resources in tags and is a naming prefix"
  default     = "dev"
}

locals {
  default_tags = merge(
    var.base_tags,
    {
      "env" = var.environment
    }
  )
}