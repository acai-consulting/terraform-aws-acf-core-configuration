Set-Location -Path $PSScriptRoot

terraform init
terraform apply --auto-approve --var-file=tc_l3.tfvars
terraform output > tc_l3.txt

terraform apply --auto-approve --var-file=tc_l8.tfvars
terraform output > tc_l8.txt

terraform apply --auto-approve --var-file=tc_list.tfvars
terraform output > tc_list.txt

rm terraform.tfstate
rm .terraform.lock.hcl

