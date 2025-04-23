package test

import (
	"testing"
	"github.com/stretchr/testify/assert"
	"github.com/gruntwork-io/terratest/modules/terraform"
)

func TestExample4Complete(t *testing.T) {
	// retryable errors in terraform testing.
	t.Log("Starting Sample Module test")


	// Create IAM Roles
	terraformCoreConfigurationRoles := &terraform.Options{
		TerraformDir: "../examples/ssm-ps-4",
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
		TerraformDir: "../examples/ssm-ps-4",
		NoColor:      false,
		Lock:         true,
		Targets: 	  []string {
			"local.configuration_add_on",
			"module.core_configuration_writer.module.complex_map_to_simple_map",
			"module.core_configuration_writer.local.flattened_configuration_add_on",
			"module.core_configuration_writer",
		},
	}
	defer terraform.Destroy(t, terraformWriteConfiguration1)
	terraform.InitAndApply(t, terraformWriteConfiguration1)
		
	// Read Configuration
	terraformReadConfiguration := &terraform.Options{
		TerraformDir: "../examples/ssm-ps-4",
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