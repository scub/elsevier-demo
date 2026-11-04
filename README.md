[mise]: https://mise.jdx.dev/getting-started.html
[Floci]: https://floci.io/
[direnv]: https://direnv.net/
[pre-commit]: https://pre-commit.com/
[act]: https://github.com/nektos/act

# Overview

This project is meant to serve as a demostration of some general practices, with the goal of achieveing the outcomes identified in the [instructions](./docs/Instructions.md) document.

## Getting started

This project uses [mise] to manage the local tool chain, install it:

```bash
mise install
```

IaC is baked into a module in `./terraform/modules` and gets consumed per-environment (ex: `./terraform/dev`). 

To use it add your AWS keys to `./terraform/dev/.envrc`, and copy `./terraform/dev/tfvars.example` adding your IP and an Email to alert on.

From there you can run `tofu init` and `tofu apply` respectively. 

## Additional information

More information about this project, it's tooling and design choices can be found in the documents outlined below:

- [Instructions](./docs/Instructions.md)
- [Tool chain](./docs/ToolChain.md)
- [pre-commit hooks](./docs/PreCommit.md)
- [Terraform](./docs/Terraform.md)
- [Cost considerations](./docs/CostConsiderations.md)
- [Improvements](./docs/Improvements.md)