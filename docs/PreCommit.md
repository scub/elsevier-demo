[conventional commits]: https://www.conventionalcommits.org/en/v1.0.0/
# pre-commit

The following actions take place as part of the pre-commit flow:

- `conventional-commits` - Ensure all commit messages adhere to the [conventional commits] specification
- `tofu fmt` - Ensure IaC is formatted
- `tofu validate` - Naive IaC validation
- `tflint` - Validate quality and consistency of IaC
- `terrafom-docs` - Generate IaC documentation