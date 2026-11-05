locals {
  buckets = {
    # alb_logs = { name = "${local.name_prefix}alb_logs_${data.aws_caller_identity.current.id}", versioning = false, purpose = "alb logs" },
    state_bucket = {
      name             = "${replace(local.name_prefix, "_", "-")}${var.state_bucket}-${data.aws_caller_identity.current.id}-${var.region}-an"
      versioning       = true
      purpose          = "Terraform State"
      bucket_namespace = "account-regional"
      lifecycle_rules = [{
        id      = "delete-older-state-versions"
        enabled = true

        filter = {}

        # Keep the last 3 non-current objects, delete anything older after 7 days
        noncurrent_version_expiration = {
          noncurrent_days           = 7
          newer_noncurrent_versions = 3
        }
      }]
    }
    web_assets = {
      name             = "${replace(local.name_prefix, "_", "-")}assets-${data.aws_caller_identity.current.id}-${var.region}-an"
      versioning       = true
      purpose          = "Application assets"
      bucket_namespace = "account-regional"
      lifecycle_rules = [{
        id      = "delete-non-current-versions"
        enabled = true

        filter = {}

        # Keep the last 3 non-current objects, delete anything older after 7 days
        noncurrent_version_expiration = {
          noncurrent_days           = 7
          newer_noncurrent_versions = 3
        }
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

  # Failed uploads are always cleaned up
  lifecycle_rule = concat(
    [
      {
        id      = "cleanup-failed-uploads"
        enabled = true

        # Target all objects
        filter = {}

        # Delete incomplete multipart uploads after 1 day
        abort_incomplete_multipart_upload_days = 1
      }
    ],
    try(each.value.lifecycle_rules, []),
  )

  intelligent_tiering = {
    # ARCHIVE_ACCESS min 90, DEEP_ARCHIVE_ACCESS min 180
    archive_config = {
      status = "Enabled"
      tiering = {
        ARCHIVE_ACCESS      = { days = 90 }
        DEEP_ARCHIVE_ACCESS = { days = 180 }
      }
    }
  }

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
  output_path = "app.zip"

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