configuration_add_on = {
  database = {
    connections = [
      {
        name = "primary"
        host = "db1.example.com"
        port = 5432
        settings = {
          max_connections = 100
          timeout = 30
        }
        tags = ["production", "primary"]
      },
      {
        name = "secondary"
        host = "db2.example.com" 
        port = 5432
        settings = {
          max_connections = 50
          timeout = 15
          backup_enabled = true
        }
        tags = ["production", "backup"]
      }
    ]
  }
  application = {
    services = ["api", "worker", "scheduler"]
    environments = [
      {
        name = "prod"
        replicas = 3
        resources = {
          cpu = "2"
          memory = "4Gi"
        }
      },
      {
        name = "staging"
        replicas = 1
        resources = {
          cpu = "1"
          memory = "2Gi"
        }
      }
    ]
  }
}
prefix = "/test"Set-Location -Path $PSScriptRoot

terraform init

Write-Host "Testing Level 3 nested structures..."
terraform apply --auto-approve --var-file=tc_l3.tfvars
terraform output > tc_l3.txt

Write-Host "Testing Level 8 nested structures..."
terraform apply --auto-approve --var-file=tc_l8.tfvars
terraform output > tc_l8.txt

Write-Host "Testing basic list structures..."
terraform apply --auto-approve --var-file=tc_list.tfvars
terraform output > tc_list.txt

Write-Host "Testing list of strings..."
terraform apply --auto-approve --var-file=tc_list_string.tfvars
terraform output > tc_list_string.txt

Write-Host "Testing list of dictionaries..."
terraform apply --auto-approve --var-file=tc_list_dict.tfvars
terraform output > tc_list_dict.txt

Write-Host "Testing complex mixed structures..."
terraform apply --auto-approve --var-file=tc_complex_mixed.tfvars
terraform output > tc_complex_mixed.txt

# Clean up
rm terraform.tfstate
rm .terraform.lock.hcl

Write-Host "All tests completed. Check output files for results."