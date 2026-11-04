package test

import (
	// "os"
	"testing"
	"time"

	http_helper "github.com/gruntwork-io/terratest/modules/http-helper"

	"github.com/gruntwork-io/terratest/modules/terraform"
	// "github.com/stretchr/testify/assert"
)

func TestTerraformDemoModule(t *testing.T) {
	t.Parallel()

	moduleFolder := test_structure.CopyTerraformFolderToTemp(t, "../", "terraform/modules/demo")
	planFilePath := filepath.Join(moduleFolder, "plan.out")

	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: "../terraform/modules/demo/",
		TerraformBinary: "tofu",
		PlanFilePath: planFilePath,
	})

	// Run `terraform init`, `terraform plan`, and `terraform show` and fail the test if there are any errors
	plan := terraform.InitAndPlanAndShowWithStructContext(t, t.Context(), terraformOptions)

	// introspect the plan values
	terraform.RequirePlannedValuesMapKeyExists(t, plan, "module.instances[\"webserver\"].aws_instance.this[0]")

	webSecurityGroupResource := plan.ResourcePlannedValuesMap["module.web_sg.aws_vpc_security_group_ingress_rule.this[\"allow-bastion-http\"]"]

	ec2WebserverResource := plan.ResourcePlannedValuesMap["module.instances[\"webserver\"].aws_instance.this[0]"]
	ec2Tags := ec2WebserverResource.AttributeValues["tags"].(map[string]interface{})

	// assert.Equal(t, map[string]interface{}{"Name": expectedName}, ec2Tags)

	// defer terraform.DestroyContext(t, t.Context(), terraformOptions)

	// terraform.InitAndApplyContext(t, t.Context(), terraformOptions)

	// publicIP := terraform.OutputContext(t, t.Context(), terraformOptions, "public_ip")
	// url := "http://" + publicIP + ":8080"

	// http_helper.HTTPGetWithRetryContext(t, t.Context(), url, nil, 200, "Hello, World!", 30, 5*time.Second)

	// output := terraform.OutputContext(t, t.Context(), terraformOptions, "hello_world")
	// assert.Equal(t, "Hello, World!", output)
}


// // TestDemoEnvironmentPlan checks that the module initializes and plans cleanly
// // against floci. It creates nothing, so it is cheap enough for pre-commit.
// // func TestDemoEnvironmentPlan(t *testing.T) {
// // 	t.Parallel()
// // 	// requireFloci(t)

// // 	opts := options(t, nil)
// // 	opts.PlanFilePath = t.TempDir() + "/plan.out"

// // 	// 0 = no changes, 2 = changes pending; 1 (error) fails the test.
// // 	exit := terraform.InitAndPlanWithExitCode(t, opts)
// // 	assert.Contains(t, []int{0, 2}, exit, "plan must succeed")
// // }

// // // TestDemoEnvironmentApply applies the module to floci, checks idempotency
// // // and destroys it again. Slow, so opt in with TERRATEST_APPLY=1.
// // func TestDemoEnvironmentApply(t *testing.T) {
// // 	if os.Getenv("TERRATEST_APPLY") == "" {
// // 		t.Skip("set TERRATEST_APPLY=1 to run apply/destroy tests")
// // 	}
// // 	// requireFloci(t)

// // 	opts := options(t, nil)
// // 	defer terraform.Destroy(t, opts)

// // 	terraform.InitAndApply(t, opts)

// // 	exit := terraform.PlanExitCode(t, opts)
// // 	assert.Equal(t, 0, exit, "second plan should be empty (idempotent)")
// // }
