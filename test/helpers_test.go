package test

import (
	"maps"
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
)

const modulePath = "../terraform/dev"

// options returns terraform options that use OpenTofu, matching mise.toml
func options(t *testing.T, vars map[string]interface{}) *terraform.Options {
	t.Helper()

	defaultVars := map[string]interface{}{
		"personal_ip":    "68.83.160.144",
		"alerting_email": "penny@loves-to.dev",
	}

	mergedVars := make(map[string]interface{}, len(defaultVars))
	maps.Copy(mergedVars, defaultVars)
	maps.Copy(mergedVars, vars)

	return terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformBinary: "tofu",
		TerraformDir:    modulePath,
		Vars:            mergedVars,
		NoColor:         true,
	})
}
