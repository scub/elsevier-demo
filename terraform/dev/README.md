## Requirements

| Name | Version |
| ---- | ------- |
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 1.13 |
| <a name="requirement_archive"></a> [archive](#requirement\_archive) | ~> 2.4 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 6.0 |

## Providers

No providers.

## Modules

| Name | Source | Version |
| ---- | ------ | ------- |
| <a name="module_dev_app_deployment"></a> [dev\_app\_deployment](#module\_dev\_app\_deployment) | ../modules/demo | n/a |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_alerting_email"></a> [alerting\_email](#input\_alerting\_email) | This email is used for cloudwatch alerts through an SNS subscription | `string` | n/a | yes |
| <a name="input_base_tags"></a> [base\_tags](#input\_base\_tags) | n/a | `map(string)` | <pre>{<br/>  "managed-by": "terraform",<br/>  "project": "demo",<br/>  "scope": "elsevier",<br/>  "source": "https://github.com/scub/elsevier-demo/",<br/>  "user": "penny"<br/>}</pre> | no |
| <a name="input_environment"></a> [environment](#input\_environment) | This environment is attached to resources in tags and is a naming prefix | `string` | `"dev"` | no |
| <a name="input_personal_ip"></a> [personal\_ip](#input\_personal\_ip) | This IP is attached to the Bastion hosts security groups | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | What region are we deploying into | `string` | `"us-east-1"` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_dns"></a> [dns](#output\_dns) | n/a |
