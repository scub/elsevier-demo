locals {
  buckets = {
    # alb_logs = { name = "${local.name_prefix}alb_logs_${data.aws_caller_identity.current.id}", versioning = false, purpose = "alb logs" },
    state_bucket = {
      name             = "${replace(local.name_prefix, "_", "-")}${var.state_bucket}-${data.aws_caller_identity.current.id}-${var.region}-an"
      versioning       = true
      purpose          = "Terraform State"
      bucket_namespace = "account-regional"
    }
    web_assets = {
      name             = "${replace(local.name_prefix, "_", "-")}assets-${data.aws_caller_identity.current.id}-${var.region}-an"
      versioning       = false
      purpose          = "Application assets"
      bucket_namespace = "account-regional"
      lifecycle_rules = [{
        id                                     = "old_assets"
        enabled                                = true
        abort_incomplete_multipart_upload_days = null
        expiration = [{
          days = 30
        }]
        transition                    = []
        noncurrent_version_transition = []
        noncurrent_version_expiration = []
      }]
    }
  }
}

module "s3_buckets" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "~> 5.17"

  for_each = local.buckets

  bucket = each.value.name
  acl    = "private"

  control_object_ownership = true
  object_ownership         = "ObjectWriter"

  bucket_namespace = try(each.value.bucket_namespace, "")

  versioning = {
    enabled = each.value.versioning
  }

  tags = merge(
    local.default_tags,
    {
      "purpose" = each.value.purpose
    }
  )
}


data "archive_file" "webapp" {
  type        = "zip"
  source_dir  = "${path.module}/../../../app"
  output_path = "/tmp/app.zip"

  excludes = [
    "${path.module}/../../../app/.venv",
    "${path.module}/../../../app/__pycache__"
  ]

}

resource "aws_s3_object" "webapp_bundle" {
  bucket = module.s3_buckets["web_assets"].s3_bucket_id
  key    = "webapp/bundle.zip"
  source = data.archive_file.webapp.output_path

  # Use etag for unencrypted objects to detect content changes
  etag = filemd5(data.archive_file.webapp.output_path)
}

resource "aws_iam_policy" "access_asset_bucket" {
  name        = "${module.s3_buckets["web_assets"].s3_bucket_id}-accessor"
  description = "Access assets in the web bucket"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = ["s3:GetObject", "s3:HeadObject", "s3:ListObject", "s3:ListBucket"]
      Resource = [
        module.s3_buckets["web_assets"].s3_bucket_arn,
        "${module.s3_buckets["web_assets"].s3_bucket_arn}/*"
      ]
    }]
  })
}

resource "aws_iam_role_policy_attachment" "webserver_access_asset_bucket" {
  role       = module.autoscaling["webserver"].iam_role_name
  policy_arn = aws_iam_policy.access_asset_bucket.arn
}