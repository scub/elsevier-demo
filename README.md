[mise]: https://mise.jdx.dev/getting-started.html
[Floci]: https://floci.io/
[direnv]: https://direnv.net/
[pre-commit]: https://pre-commit.com/
[act]: https://github.com/nektos/act

# Overview

This project is meant to serve as a demostration of some general practices, with the goal of achieveing the outcomes identified in the [objective brief](./docs/ObjectiveBrief.md).

## Getting started

This project uses [mise] to manage the local [tool chain](./docs/ToolChain.md), install it:

```bash
mise install
```

IaC is baked into a module in `./terraform/modules` and gets consumed per-environment (ex: `./terraform/dev`). 

To use it add your AWS keys to `./terraform/dev/.envrc`, and copy `./terraform/dev/terraform.tfvars.example` to `./terraform/dev/terraform.tfvars` adding your IP and an Email to alert on.

```bash
# Populate tfvars
cat > ./terraform/dev/terraform.tfvars << EOF
personal_ip = "$(curl -Lso - icanhazip.com)"
environment = "dev"
alerting_email = "penny@loves-to.dev"
EOF

# Populate .envrc
cat > ./terraform/dev/.envrc << EOF
source_up 

export AWS_DEFAULT_REGION=us-east-1
export AWS_ACCESS_KEY_ID=<ACCESS_KEY>
export AWS_SECRET_ACCESS_KEY=<SECRET_ACCESS_KEY>
EOF
```

From there you can run `tofu init` and `tofu apply` respectively.

### Bootstrapping CI

In order for CI to work as expected you'll need create an s3 bucket to hold our state, to do so
you'll want to run a targeted apply for the state bucket and IAM role for Github Actions, take the
value output for "state_bucket" and insert it into `providers.tf` and migrate the local state to it:


```bash
tofu init ; tofu apply -target='module.app_dev.module.s3_buckets["state_bucket"]' -target='module.app_dev.aws_iam_openid_connect_provider.github' -target='module.app_dev.aws_iam_role.github_actions' -target='module.app_dev.aws_iam_role_policy_attachment.terraform_admin' --auto-approve
sed -i -e "s|  bucket = \"\"|  bucket = \"$(tofu output -raw state_bucket)\"|; s|#||" providers.tf
tofu init -migrate-state -force-copy
```

Take the `github_actions_role` output and add it to the pipeline variables as `AWS_ROLE_ARN_DEV`, making sure to add
`PERSONAL_IP` and `ALERTING_EMAIL` variables. Once these 3 values are prepped, when the provider changes merge into
`main` a full end to end apply run should occur.

## Additional information

More information about this project, it's tooling and design choices can be found in the documents outlined below:

- [Tool chain](./docs/ToolChain.md)
- [pre-commit hooks](./docs/PreCommit.md)
- [Terraform](./docs/Terraform.md)
- [Cost Considerations](./docs/CostConsiderations.md)
- [Improvements](./docs/Improvements.md)
- [Objective Brief](./docs/ObjectiveBrief.md)