package test

import (
	"testing"
	"github.com/stretchr/testify/assert"
	"github.com/gruntwork-io/terratest/modules/terraform"
)

func TestExample1Complete(t *testing.T) {
	// retryable errors in terraform testing.
	t.Log("Starting Sample Module test")


	// Create IAM Roles
	terraformCoreConfigurationRoles := &terraform.Options{
		TerraformDir: "../examples/ssm-ps-1",
		NoColor:      false,
		Lock:         true,
		Targets: 	  []string {
			"module.core_configuration_roles", 
		},
	}
	defer terraform.Destroy(t, terraformCoreConfigurationRoles)
	terraform.InitAndApply(t, terraformCoreConfigurationRoles)

	// Write Configuration
	terraformWriteConfiguration := &terraform.Options{
		TerraformDir: "../examples/ssm-ps-1",
		NoColor:      false,
		Lock:         true,
		Targets: 	  []string {
			"local.configuration_add_on",
			"module.core_configuration_writer.module.complex_map_to_simple_map",
			"module.core_configuration_writer",
		},
	}
	defer terraform.Destroy(t, terraformWriteConfiguration)
	terraform.InitAndApply(t, terraformWriteConfiguration)

	// Read Configuration
	terraformReadConfiguration := &terraform.Options{
		TerraformDir: "../examples/ssm-ps-1",
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