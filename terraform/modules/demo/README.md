<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
| ---- | ------- |
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 1.13 |
| <a name="requirement_archive"></a> [archive](#requirement\_archive) | ~> 2.8 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 6.71 |

## Providers

| Name | Version |
| ---- | ------- |
| <a name="provider_archive"></a> [archive](#provider\_archive) | 2.8.1 |
| <a name="provider_aws"></a> [aws](#provider\_aws) | 6.72.0 |

## Modules

| Name | Source | Version |
| ---- | ------ | ------- |
| <a name="module_alb"></a> [alb](#module\_alb) | terraform-aws-modules/alb/aws | ~> 10.5 |
| <a name="module_alerting_sns_topic"></a> [alerting\_sns\_topic](#module\_alerting\_sns\_topic) | terraform-aws-modules/sns/aws | ~> 7.2 |
| <a name="module_autoscaling"></a> [autoscaling](#module\_autoscaling) | terraform-aws-modules/autoscaling/aws | ~> 9.3 |
| <a name="module_instances"></a> [instances](#module\_instances) | terraform-aws-modules/ec2-instance/aws | ~> 6.4 |
| <a name="module_metric_alarm_cpu"></a> [metric\_alarm\_cpu](#module\_metric\_alarm\_cpu) | terraform-aws-modules/cloudwatch/aws//modules/metric-alarm | ~> 6.0 |
| <a name="module_s3_buckets"></a> [s3\_buckets](#module\_s3\_buckets) | terraform-aws-modules/s3-bucket/aws | ~> 5.17 |
| <a name="module_secrets_manager"></a> [secrets\_manager](#module\_secrets\_manager) | terraform-aws-modules/secrets-manager/aws | ~> 2.2 |
| <a name="module_vpc"></a> [vpc](#module\_vpc) | terraform-aws-modules/vpc/aws | ~> 6.7 |
| <a name="module_web_sg"></a> [web\_sg](#module\_web\_sg) | terraform-aws-modules/security-group/aws | ~> 6.0 |

## Resources

| Name | Type |
| ---- | ---- |
| [aws_iam_openid_connect_provider.github](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_openid_connect_provider) | resource |
| [aws_iam_policy.access_asset_bucket](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.terraform_deploy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.web_secretsmanager](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role.github_actions](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.terraform_admin](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.web_access_secretsmanager](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.webserver_access_asset_bucket](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_s3_object.webapp_bundle](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_object) | resource |
| [archive_file.webapp](https://registry.terraform.io/providers/hashicorp/archive/latest/docs/data-sources/file) | data source |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_alerting_email"></a> [alerting\_email](#input\_alerting\_email) | n/a | `string` | n/a | yes |
| <a name="input_base_tags"></a> [base\_tags](#input\_base\_tags) | n/a | `map(string)` | <pre>{<br/>  "managed-by": "terraform",<br/>  "project": "demo",<br/>  "scope": "elsevier",<br/>  "source": "https://github.com/scub/elsevier-demo/",<br/>  "user": "penny"<br/>}</pre> | no |
| <a name="input_environment"></a> [environment](#input\_environment) | n/a | `string` | `"dev"` | no |
| <a name="input_personal_ip"></a> [personal\_ip](#input\_personal\_ip) | n/a | `string` | n/a | yes |
| <a name="input_private_subnet_cidrs"></a> [private\_subnet\_cidrs](#input\_private\_subnet\_cidrs) | n/a | `list(string)` | <pre>[<br/>  "10.0.1.0/24",<br/>  "10.0.2.0/24",<br/>  "10.0.3.0/24"<br/>]</pre> | no |
| <a name="input_public_subnet_cidrs"></a> [public\_subnet\_cidrs](#input\_public\_subnet\_cidrs) | n/a | `list(string)` | <pre>[<br/>  "10.0.101.0/24",<br/>  "10.0.102.0/24",<br/>  "10.0.103.0/24"<br/>]</pre> | no |
| <a name="input_region"></a> [region](#input\_region) | n/a | `string` | `"us-east-1"` | no |
| <a name="input_state_bucket"></a> [state\_bucket](#input\_state\_bucket) | n/a | `string` | `"tfstate"` | no |
| <a name="input_vpc_cidr"></a> [vpc\_cidr](#input\_vpc\_cidr) | n/a | `string` | `"10.0.0.0/16"` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_alb_dns"></a> [alb\_dns](#output\_alb\_dns) | n/a |
| <a name="output_buckets"></a> [buckets](#output\_buckets) | n/a |
| <a name="output_github_actions_role"></a> [github\_actions\_role](#output\_github\_actions\_role) | n/a |
| <a name="output_private_ip"></a> [private\_ip](#output\_private\_ip) | n/a |
| <a name="output_public_ip"></a> [public\_ip](#output\_public\_ip) | n/a |
<!-- END_TF_DOCS -->