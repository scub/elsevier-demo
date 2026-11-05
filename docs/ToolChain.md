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

- [act]
- [conventional-commits]
- [Floci]
- [direnv]
- [OpenTofu]
- [pre-commit]
- [tflint]
- [terraform-docs]
- [terratest]

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

[terratest] provides simple validation on terraform plans and ensures connectivity post apply

```bash
go test -v -count=1 -timeout 10m ./test/...
```