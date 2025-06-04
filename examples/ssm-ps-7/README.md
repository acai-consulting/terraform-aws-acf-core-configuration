# SSM Parameter Store Example 7 - List of Dictionaries

This example demonstrates the terraform-aws-acf-core-configuration module with dictionary list configurations including:
- Arrays of objects/dictionaries
- Mixed data types within dictionaries
- Nested configurations within list items
- Complex mixed structures

## Usage

```bash
terraform init
terraform plan -var-file="../../../shared/_local-test/tc_list_dict.tfvars"
terraform apply -var-file="../../../shared/_local-test/tc_list_dict.tfvars"
```

## Test Structure

This example tests:
- Dictionary list parameter handling
- Nested object configurations within arrays
- Mixed data type support in dictionaries
- Complex nested structures with arrays and objects