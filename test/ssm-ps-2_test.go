package test

import (
	"testing"
	"github.com/stretchr/testify/assert"
	"github.com/gruntwork-io/terratest/modules/terraform"
)

func TestExample2Complete(t *testing.T) {
	// retryable errors in terraform testing.
	t.Log("Starting Sample Module test")

	terraformDir := "../examples/ssm-ps-2"

    // Clean up backend override file after test
    defer func() {
        // Also clean up local state files
        os.Remove(filepath.Join(terraformDir, "terraform.tfstate"))
        os.Remove(filepath.Join(terraformDir, "terraform.tfstate.backup"))
        os.RemoveAll(filepath.Join(terraformDir, ".terraform"))
    }()

	// Create IAM Roles
	terraformCoreConfigurationRoles := &terraform.Options{
		TerraformDir: terraformDir,
		NoColor:      false,
		Lock:         true,
		Targets: 	  []string {
			"module.core_configuration_roles", 
		},
	}
	defer terraform.Destroy(t, terraformCoreConfigurationRoles)
	terraform.InitAndApply(t, terraformCoreConfigurationRoles)

	// Write Configuration 1
	terraformWriteConfiguration1 := &terraform.Options{
		TerraformDir: terraformDir,
		NoColor:      false,
		Lock:         true,
		Targets: 	  []string {
			"module.core_configuration_writer.module.complex_map_to_simple_map",
			"module.core_configuration_writer",
		},
	}
	defer terraform.Destroy(t, terraformWriteConfiguration1)
	terraform.InitAndApply(t, terraformWriteConfiguration1)
		
	// Read Configuration
	terraformReadConfiguration := &terraform.Options{
		TerraformDir: terraformDir,
		NoColor:      false,
		Lock:         true,
		Targets: 	  []string {
			"module.core_configuration_reader",
		},
	}
	defer terraform.Destroy(t, terraformReadConfiguration)
	terraform.InitAndApply(t, terraformReadConfiguration)
	
	
	// Retrieve the 'test_success' output
	testSuccessOutput := terraform.Output(t, terraformReadConfiguration, "test_success")

	// Assert that 'test_success' equals "true"
	assert.Equal(t, "true", testSuccessOutput, "The test_success output is not true")
}