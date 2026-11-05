package test

import (
	"os"
	"strings"
	"testing"
	"time"

	http_helper "github.com/gruntwork-io/terratest/modules/http-helper"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

// TestDemoEnvironmentPlan checks that the module initializes and plans cleanly.
// It creates nothing, so it is cheap enough for pre-commit.
func TestDemoEnvironmentPlan(t *testing.T) {
	t.Parallel()

	opts := options(t, nil)
	opts.PlanFilePath = t.TempDir() + "/plan.out"

	// 0 = no changes, 2 = changes pending; 1 (error) fails the test.
	exit := terraform.InitAndPlanWithExitCodeContext(t, t.Context(), opts)
	assert.Contains(t, []int{0, 2}, exit, "plan must succeed")
}

// TestDemoEnvironmentApply applies the module, checks idempotency
// and destroys it again. Slow, so opt in with TERRATEST_APPLY=1.
func TestDemoEnvironmentApplyAndConnect(t *testing.T) {
	if os.Getenv("TERRATEST_APPLY") == "" {
		t.Skip("set TERRATEST_APPLY=1 to run apply/connectivity tests")
	}

	opts := options(t, nil)

	terraform.InitAndApplyContext(t, t.Context(), opts)

	publicDNS := terraform.OutputContext(t, t.Context(), opts, "dns")
	url := "http://" + publicDNS + ":80"

	maxRetries := 5

	http_helper.HTTPGetWithRetryWithCustomValidationContext(t, t.Context(), url, nil, maxRetries, 5*time.Second,
		func(statusCode int, body string) bool {
			return statusCode == 200 &&
				strings.Contains(body, "Hello, World!") &&
				strings.Contains(body, "webserver-secret-value")
		},
	)

	exit := terraform.PlanExitCodeContext(t, t.Context(), opts)
	assert.Equal(t, 0, exit, "second plan should be empty (idempotent)")
}
