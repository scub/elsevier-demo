[act]: https://github.com/nektos/act
[conventional-commits]: https://www.conventionalcommits.org/en/v1.0.0/
[direnv]: https://direnv.net/
[Floci]: https://floci.io/
[infracost]: https://www.infracost.io/
[OpenTofu]: https://opentofu.org/
[pre-commit]: https://pre-commit.com/
[terraform-docs]: https://terraform-docs.io/
[terratest]: https://terratest.gruntwork.io/
[tflint]: https://github.com/terraform-linters/tflint
[trivy]: https://trivy.dev/

# Tools used

- [OpenTofu]
- [Floci]
- [direnv]
- [act]
- [pre-commit]
- [tflint]
- [terraform-docs]
- [conventional-commits]

## Motivations

[direnv] manages local environment variables

```bash
direnv allow
```

[pre-commit] manages commit health and runs on every commit

```bash
pre-commit run --all
```

[Floci] is configured in [docker-compose](./docker-compose.yaml) to provide a local emulator of AWS

```bash
docker compose up -d
```

[act] is used to test Github Actions locally

```bash
cd .github/workflows && act
```

