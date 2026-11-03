module "secrets_manager" {
  source  = "terraform-aws-modules/secrets-manager/aws"
  version = "~> 2.2"

  name        = "/${var.environment}/webserver_secret"
  description = "Webserver test secret values"

  create_secret_version = true
  secret_string         = "webserver-secret-value"

  tags = local.default_tags
}

resource "aws_iam_policy" "web_secretsmanager" {
  name        = "${local.name_prefix}web_secretsmanager"
  path        = "/"
  description = "Allow webserver access to secretsmanager secret"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "SecretsManager:ListSecrets",
          "SecretsManager:GetSecretValue",
        ]
        Effect   = "Allow"
        Resource = module.secrets_manager.secret_arn
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "web_access_secretsmanager" {
  role       = module.instances["webserver"].iam_role_name
  policy_arn = aws_iam_policy.web_secretsmanager.arn
}