package test

import (
    "testing"
    "github.com/stretchr/testify/assert"
    "github.com/gruntwork-io/terratest/modules/terraform"
)

func TestExample5ComplexMixed(t *testing.T) {
    // retryable errors in terraform testing.
    t.Log("Starting Complex Mixed Structure Module test")

    terraformDir := "../examples/ssm-ps-5"

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

    // Write Configuration
    terraformWriteConfiguration := &terraform.Options{
        TerraformDir: terraformDir,
        NoColor:      false,
        Lock:         true,
        Targets: 	  []string {
            "module.core_configuration_writer.module.complex_map_to_simple_map",
            "module.core_configuration_writer",
			"module.core_configuration_reader",
        },
    }
    defer terraform.Destroy(t, terraformWriteConfiguration)
    terraform.InitAndApply(t, terraformWriteConfiguration)
        
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
    
    // Retrieve the 'complex_structure_test' output
    complexStructureOutput := terraform.Output(t, terraformReadConfiguration, "complex_structure_test")

    // Assert that 'test_success' equals "true"
    assert.Equal(t, "true", testSuccessOutput, "The test_success output is not true")
    
    // Assert that complex structure test passes
    assert.Equal(t, "true", complexStructureOutput, "The complex_structure_test output is not true")
}