resource "aws_iam_openid_connect_provider" "github" {
  url             = "https://token.actions.githubusercontent.com"
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = ["6938fd4d98bab03faadb97b34396831e3780aea1"]
}

resource "aws_iam_role" "github_actions" {
  name = "github-actions-terraform"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = aws_iam_openid_connect_provider.github.arn
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
          }
          StringLike = {
            "token.actions.githubusercontent.com:sub" = "repo:scub/elsevier-demo:ref:refs/heads/main"
          }
        }
      }
    ]
  })
}

locals {
  tf_account_id  = data.aws_caller_identity.current.account_id
  tf_dash_prefix = replace(local.name_prefix, "_", "-")
  tf_bucket_arns = [for b in local.buckets : "arn:aws:s3:::${b.name}"]
  tf_object_arns = [for b in local.buckets : "arn:aws:s3:::${b.name}/*"]
}

# Least-privilege policy for the GitHub Actions role to plan/apply/destroy every resource in this module.
# Actions that do not support resource-level permissions are scoped to the deployment region instead.
resource "aws_iam_policy" "terraform_deploy" {
  name        = "github-actions-terraform-deploy"
  description = "Least privilege permissions for GitHub Actions to apply the demo Terraform stack"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        # VPC, subnets, IGW, NAT, EIP, route tables, security groups, launch templates, instances.
        # Most EC2 actions have no resource-level support, so restrict by region.
        Sid    = "Ec2Networking"
        Effect = "Allow"
        Action = [
          "ec2:Describe*",
          "ec2:GetLaunchTemplateData",
          "ec2:CreateVpc", "ec2:DeleteVpc", "ec2:ModifyVpcAttribute",
          "ec2:CreateSubnet", "ec2:DeleteSubnet", "ec2:ModifySubnetAttribute",
          "ec2:CreateInternetGateway", "ec2:DeleteInternetGateway",
          "ec2:AttachInternetGateway", "ec2:DetachInternetGateway",
          "ec2:CreateRouteTable", "ec2:DeleteRouteTable",
          "ec2:CreateRoute", "ec2:DeleteRoute", "ec2:ReplaceRoute",
          "ec2:AssociateRouteTable", "ec2:DisassociateRouteTable",
          "ec2:AllocateAddress", "ec2:ReleaseAddress",
          "ec2:AssociateAddress", "ec2:DisassociateAddress",
          "ec2:CreateNatGateway", "ec2:DeleteNatGateway",
          "ec2:CreateSecurityGroup", "ec2:DeleteSecurityGroup",
          "ec2:AuthorizeSecurityGroupIngress", "ec2:AuthorizeSecurityGroupEgress",
          "ec2:RevokeSecurityGroupIngress", "ec2:RevokeSecurityGroupEgress",
          "ec2:ModifySecurityGroupRules", "ec2:UpdateSecurityGroupRuleDescriptionsIngress",
          "ec2:UpdateSecurityGroupRuleDescriptionsEgress",
          "ec2:CreateNetworkAcl", "ec2:DeleteNetworkAcl",
          "ec2:CreateNetworkAclEntry", "ec2:DeleteNetworkAclEntry", "ec2:ReplaceNetworkAclEntry",
          "ec2:ReplaceNetworkAclAssociation",
          "ec2:CreateLaunchTemplate", "ec2:DeleteLaunchTemplate",
          "ec2:CreateLaunchTemplateVersion", "ec2:ModifyLaunchTemplate",
          "ec2:RunInstances", "ec2:TerminateInstances", "ec2:StopInstances", "ec2:StartInstances",
          "ec2:ModifyInstanceAttribute", "ec2:ModifyInstanceMetadataOptions",
          "ec2:CreateTags", "ec2:DeleteTags",
        ]
        Resource = "*"
        Condition = {
          StringEquals = { "aws:RequestedRegion" = var.region }
        }
      },
      {
        Sid    = "AutoScaling"
        Effect = "Allow"
        Action = [
          "autoscaling:Describe*",
          "autoscaling:GetPredictiveScalingForecast",
        ]
        Resource = "*"
      },
      {
        Sid    = "AutoScalingManage"
        Effect = "Allow"
        Action = [
          "autoscaling:CreateAutoScalingGroup", "autoscaling:UpdateAutoScalingGroup",
          "autoscaling:DeleteAutoScalingGroup", "autoscaling:CreateOrUpdateTags", "autoscaling:DeleteTags",
          "autoscaling:PutScalingPolicy", "autoscaling:DeletePolicy",
          "autoscaling:AttachTrafficSources", "autoscaling:DetachTrafficSources",
          "autoscaling:SetDesiredCapacity", "autoscaling:SuspendProcesses", "autoscaling:ResumeProcesses",
        ]
        Resource = "arn:aws:autoscaling:${var.region}:${local.tf_account_id}:autoScalingGroup:*:autoScalingGroupName/${local.name_prefix}*"
      },
      {
        Sid      = "ElbRead"
        Effect   = "Allow"
        Action   = ["elasticloadbalancing:Describe*"]
        Resource = "*"
      },
      {
        Sid    = "ElbManage"
        Effect = "Allow"
        Action = [
          "elasticloadbalancing:CreateLoadBalancer", "elasticloadbalancing:DeleteLoadBalancer",
          "elasticloadbalancing:ModifyLoadBalancerAttributes", "elasticloadbalancing:SetSecurityGroups",
          "elasticloadbalancing:SetSubnets",
          "elasticloadbalancing:CreateTargetGroup", "elasticloadbalancing:DeleteTargetGroup",
          "elasticloadbalancing:ModifyTargetGroup", "elasticloadbalancing:ModifyTargetGroupAttributes",
          "elasticloadbalancing:CreateListener", "elasticloadbalancing:DeleteListener",
          "elasticloadbalancing:ModifyListener", "elasticloadbalancing:AddTags",
          "elasticloadbalancing:RemoveTags",
        ]
        Resource = [
          "arn:aws:elasticloadbalancing:${var.region}:${local.tf_account_id}:loadbalancer/app/${local.tf_dash_prefix}*/*",
          "arn:aws:elasticloadbalancing:${var.region}:${local.tf_account_id}:targetgroup/${local.tf_dash_prefix}*/*",
          "arn:aws:elasticloadbalancing:${var.region}:${local.tf_account_id}:listener/app/${local.tf_dash_prefix}*/*/*",
        ]
      },
      {
        Sid    = "ServiceLinkedRoles"
        Effect = "Allow"
        Action = ["iam:CreateServiceLinkedRole"]
        Resource = [
          "arn:aws:iam::${local.tf_account_id}:role/aws-service-role/autoscaling.amazonaws.com/*",
          "arn:aws:iam::${local.tf_account_id}:role/aws-service-role/elasticloadbalancing.amazonaws.com/*",
        ]
      },
      {
        # Roles/instance profiles created by the ASG + EC2 modules, plus this role itself.
        Sid    = "IamRolesAndProfiles"
        Effect = "Allow"
        Action = [
          "iam:CreateRole", "iam:DeleteRole", "iam:GetRole", "iam:UpdateRole",
          "iam:UpdateAssumeRolePolicy", "iam:TagRole", "iam:UntagRole",
          "iam:ListRolePolicies", "iam:ListAttachedRolePolicies", "iam:ListInstanceProfilesForRole",
          "iam:CreateInstanceProfile", "iam:DeleteInstanceProfile", "iam:GetInstanceProfile",
          "iam:AddRoleToInstanceProfile", "iam:RemoveRoleFromInstanceProfile",
          "iam:TagInstanceProfile", "iam:UntagInstanceProfile",
        ]
        Resource = [
          "arn:aws:iam::${local.tf_account_id}:role/${local.name_prefix}*",
          "arn:aws:iam::${local.tf_account_id}:instance-profile/${local.name_prefix}*",
          aws_iam_role.github_actions.arn,
        ]
      },
      {
        Sid    = "IamAttachPolicies"
        Effect = "Allow"
        Action = ["iam:AttachRolePolicy", "iam:DetachRolePolicy"]
        Resource = [
          "arn:aws:iam::${local.tf_account_id}:role/${local.name_prefix}*",
          aws_iam_role.github_actions.arn,
        ]
        Condition = {
          ArnEquals = {
            "iam:PolicyARN" = [
              "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore",
              "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy",
              "arn:aws:iam::${local.tf_account_id}:policy/${local.name_prefix}*",
              "arn:aws:iam::${local.tf_account_id}:policy/${local.tf_dash_prefix}*",
              "arn:aws:iam::${local.tf_account_id}:policy/github-actions-terraform-deploy",
            ]
          }
        }
      },
      {
        Sid      = "IamPassInstanceRoles"
        Effect   = "Allow"
        Action   = ["iam:PassRole"]
        Resource = "arn:aws:iam::${local.tf_account_id}:role/${local.name_prefix}*"
        Condition = {
          StringEquals = { "iam:PassedToService" = "ec2.amazonaws.com" }
        }
      },
      {
        Sid    = "IamCustomPolicies"
        Effect = "Allow"
        Action = [
          "iam:CreatePolicy", "iam:DeletePolicy", "iam:GetPolicy", "iam:TagPolicy", "iam:UntagPolicy",
          "iam:CreatePolicyVersion", "iam:DeletePolicyVersion", "iam:GetPolicyVersion",
          "iam:ListPolicyVersions",
        ]
        Resource = [
          "arn:aws:iam::${local.tf_account_id}:policy/${local.name_prefix}*",
          "arn:aws:iam::${local.tf_account_id}:policy/${local.tf_dash_prefix}*",
          "arn:aws:iam::${local.tf_account_id}:policy/github-actions-terraform-deploy",
        ]
      },
      {
        Sid    = "IamReadManagedPolicies"
        Effect = "Allow"
        Action = ["iam:GetPolicy", "iam:GetPolicyVersion"]
        Resource = [
          "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore",
          "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy",
        ]
      },
      {
        Sid    = "IamOidcProvider"
        Effect = "Allow"
        Action = [
          "iam:CreateOpenIDConnectProvider", "iam:DeleteOpenIDConnectProvider",
          "iam:GetOpenIDConnectProvider", "iam:UpdateOpenIDConnectProviderThumbprint",
          "iam:AddClientIDToOpenIDConnectProvider", "iam:RemoveClientIDFromOpenIDConnectProvider",
          "iam:TagOpenIDConnectProvider", "iam:UntagOpenIDConnectProvider",
        ]
        Resource = aws_iam_openid_connect_provider.github.arn
      },
      {
        Sid    = "S3Buckets"
        Effect = "Allow"
        Action = [
          "s3:CreateBucket", "s3:DeleteBucket", "s3:ListBucket", "s3:ListBucketVersions",
          "s3:GetBucket*", "s3:GetAccelerateConfiguration", "s3:GetEncryptionConfiguration",
          "s3:GetLifecycleConfiguration", "s3:GetReplicationConfiguration",
          "s3:GetBucketTagging", "s3:PutBucketTagging",
          "s3:PutBucketAcl", "s3:PutBucketOwnershipControls", "s3:PutBucketVersioning",
          "s3:PutBucketPublicAccessBlock", "s3:PutLifecycleConfiguration",
          "s3:PutEncryptionConfiguration", "s3:PutBucketPolicy", "s3:DeleteBucketPolicy",
        ]
        Resource = local.tf_bucket_arns
      },
      {
        Sid    = "S3Objects"
        Effect = "Allow"
        Action = [
          "s3:GetObject", "s3:GetObjectVersion", "s3:GetObjectTagging", "s3:GetObjectAcl",
          "s3:PutObject", "s3:PutObjectTagging", "s3:DeleteObject", "s3:DeleteObjectVersion",
        ]
        Resource = local.tf_object_arns
      },
      {
        Sid      = "S3ListAll"
        Effect   = "Allow"
        Action   = ["s3:ListAllMyBuckets"]
        Resource = "*"
      },
      {
        Sid    = "SecretsManager"
        Effect = "Allow"
        Action = [
          "secretsmanager:CreateSecret", "secretsmanager:DeleteSecret", "secretsmanager:DescribeSecret",
          "secretsmanager:UpdateSecret", "secretsmanager:PutSecretValue", "secretsmanager:GetSecretValue",
          "secretsmanager:GetResourcePolicy", "secretsmanager:PutResourcePolicy",
          "secretsmanager:DeleteResourcePolicy", "secretsmanager:TagResource",
          "secretsmanager:UntagResource", "secretsmanager:ListSecretVersionIds",
        ]
        Resource = "arn:aws:secretsmanager:${var.region}:${local.tf_account_id}:secret:/${var.environment}/webserver_secret*"
      },
      {
        Sid    = "Sns"
        Effect = "Allow"
        Action = [
          "sns:CreateTopic", "sns:DeleteTopic", "sns:GetTopicAttributes", "sns:SetTopicAttributes",
          "sns:Subscribe", "sns:Unsubscribe", "sns:GetSubscriptionAttributes",
          "sns:ListTagsForResource", "sns:TagResource", "sns:UntagResource",
          "sns:ListSubscriptionsByTopic",
        ]
        Resource = "arn:aws:sns:${var.region}:${local.tf_account_id}:webserver_alerting_topic*"
      },
      {
        Sid      = "CloudWatchAlarms"
        Effect   = "Allow"
        Action   = ["cloudwatch:PutMetricAlarm", "cloudwatch:DeleteAlarms", "cloudwatch:TagResource", "cloudwatch:UntagResource", "cloudwatch:ListTagsForResource"]
        Resource = "arn:aws:cloudwatch:${var.region}:${local.tf_account_id}:alarm:*${local.name_prefix}CPUAlarm*"
      },
      {
        Sid      = "CloudWatchRead"
        Effect   = "Allow"
        Action   = ["cloudwatch:DescribeAlarms"]
        Resource = "*"
      },
      {
        Sid      = "Identity"
        Effect   = "Allow"
        Action   = ["sts:GetCallerIdentity"]
        Resource = "*"
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "terraform_admin" {
  role       = aws_iam_role.github_actions.name
  policy_arn = aws_iam_policy.terraform_deploy.arn
}
