package test

import (
    "testing"
    "github.com/stretchr/testify/assert"
    "github.com/gruntwork-io/terratest/modules/terraform"
)

func TestExample6ListString(t *testing.T) {
    // retryable errors in terraform testing.
    t.Log("Starting List of Strings Module test")

    terraformDir := "../examples/ssm-ps-6"

    terraformCore := &terraform.Options{
        TerraformDir: terraformDir,
        NoColor:      false,
        Lock:         true,
    }
    defer func() {
        terraform.Destroy(t, terraformCore)
        terraform.Show(t, terraformCore)
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
    terraform.InitAndApply(t, terraformCoreConfigurationRoles)

    // Write Configuration
    terraformWriteConfiguration := &terraform.Options{
        TerraformDir: terraformDir,
        NoColor:      false,
        Lock:         true,
        Targets: 	  []string {
            "module.core_configuration_writer.module.complex_map_to_simple_map",
            "module.core_configuration_writer",
        },
    }
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
    terraform.InitAndApply(t, terraformReadConfiguration)
    
    // Retrieve the 'test_success' output
    testSuccessOutput := terraform.Output(t, terraformReadConfiguration, "test_success")
    
    // Retrieve the 'string_list_test' output
    stringListOutput := terraform.Output(t, terraformReadConfiguration, "string_list_test")

    // Assert that 'test_success' equals "true"
    assert.Equal(t, "true", testSuccessOutput, "The test_success output is not true")
    
    // Assert that string list test passes
    assert.Equal(t, "true", stringListOutput, "The string_list_test output is not true")
}