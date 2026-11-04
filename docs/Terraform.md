[opentofu]: https://opentofu.org/
[terraform-docs]: https://terraform-docs.io/
[tflint]: https://github.com/terraform-linters/tflint


[terraform-aws-modules]: https://github.com/terraform-aws-modules
[terraform-aws-vpc]: https://github.com/terraform-aws-modules/terraform-aws-vpc
[terraform-aws-ec2-instance]: https://github.com/terraform-aws-modules/terraform-aws-ec2-instance
[terraform-aws-security-group]: https://github.com/terraform-aws-modules/terraform-aws-security-group
[terraform-aws-cloudwatch]: https://github.com/terraform-aws-modules/terraform-aws-cloudwatch
[terraform-aws-s3-bucket]: https://github.com/terraform-aws-modules/terraform-aws-s3-bucket
[terraform-aws-eks]: https://github.com/terraform-aws-modules/terraform-aws-eks
[terraform-aws-autoscaling]: https://github.com/terraform-aws-modules/terraform-aws-autoscaling

# Terraform

OpenTofu is used in place of Terraform

## Bootstrap terraform

Get a bucket online 

```bash
tofu init ; tofu apply -target="module.terraform_state_bucket"
```

Migrate state to it once created

```bash
tofu init -backend-config="bucket=$TF_BUCKET" -backend-config="key=$TF_ENV" -migrate-state
```

## Upstream modules

The following [terraform-aws-modules] community modules were used in this project:

- [terraform-aws-vpc]
- [terraform-aws-ec2-instance]
- [terraform-aws-security-group]
- [terraform-aws-cloudwatch]
- [terraform-aws-s3-bucket]
- [terraform-aws-eks]
- [terraform-aws-autoscaling]
