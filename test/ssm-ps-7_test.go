package test

import (
    "testing"
    "github.com/stretchr/testify/assert"
    "github.com/gruntwork-io/terratest/modules/terraform"
)

func TestExample7ListDict(t *testing.T) {
    // retryable errors in terraform testing.
    t.Log("Starting List of Dictionaries Module test")

    terraformDir := "../examples/ssm-ps-7"

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
    terraform.InitAndApply(t, terraformCore)

    // Retrieve the 'test_success' output
    testSuccessOutput := terraform.Output(t, terraformCore, "test_success")

    // Retrieve the 'dict_list_test' output
    dictListOutput := terraform.Output(t, terraformCore, "dict_list_test")

    // Retrieve the 'mixed_structure_test' output
    mixedStructureOutput := terraform.Output(t, terraformCore, "mixed_structure_test")

    // Assert that 'test_success' equals "true"
    assert.Equal(t, "true", testSuccessOutput, "The test_success output is not true")
    
    // Assert that dict list test passes
    assert.Equal(t, "true", dictListOutput, "The dict_list_test output is not true")
    
    // Assert that mixed structure test passes
    assert.Equal(t, "true", mixedStructureOutput, "The mixed_structure_test output is not true")
}