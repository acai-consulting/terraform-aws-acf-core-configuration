# SSM Parameter Store Example 5 - Complex Mixed Structures

This example demonstrates the terraform-aws-acf-core-configuration module with complex mixed data structures including:
- Nested objects with arrays
- Mixed data types (strings, numbers, booleans)
- Deep nesting levels
- Complex database connection configurations
- Application service configurations

## Usage

```bash
terraform init
terraform plan -var-file="../../../shared/_local-test/tc_complex_mixed.tfvars"
terraform apply -var-file="../../../shared/_local-test/tc_complex_mixed.tfvars"
```

## Test Structure

This example tests:
- Database connection configurations with nested settings
- Application service configurations with environment-specific settings
- Complex nested structures with mixed data types
- Parameter store read/write operations for complex data