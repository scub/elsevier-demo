module "rds" {
  source  = "terraform-aws-modules/rds/aws"
  version = "~> 7.2"

  identifier = "${replace(local.name_prefix, "_", "-")}app-rds-${var.environment}"
  # name_prefix = "${local.name_prefix}app_rds"

  engine               = "postgresql"
  major_engine_version = "16.0"
  instance_class       = "db.m6.xlarge"
  allocated_storage    = 25

  family = "postgres16"

  db_name  = "demo"
  username = "app_user"
  port     = "5436"

  tags = local.default_tags

  apply_immediately                      = true
  backup_retention_period                = 14
  cloudwatch_log_group_retention_in_days = 30
  db_subnet_group_name                   = "${local.name_prefix}rds-subnet-group"

  enabled_cloudwatch_logs_exports = ["postgresql"]
  manage_master_user_password     = false

  skip_final_snapshot = true
  storage_type        = "aurora"
}