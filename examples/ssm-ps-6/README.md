# SSM Parameter Store Example 6 - List of Strings

This example demonstrates the terraform-aws-acf-core-configuration module with string list configurations including:
- Simple string values
- Arrays of strings
- Nested objects containing string arrays
- Tag-based configurations

## Usage

```bash
terraform init
terraform plan -var-file="../../../shared/_local-test/tc_list_string.tfvars"
terraform apply -var-file="../../../shared/_local-test/tc_list_string.tfvars"
```

## Test Structure

This example tests:
- String list parameter handling
- Nested object configurations with string arrays
- Simple string parameter storage and retrieval