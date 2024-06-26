# ---------------------------------------------------------------------------------------------------------------------
# ¦ REQUIREMENTS
# ---------------------------------------------------------------------------------------------------------------------
terraform {
  required_version = ">= 1.3.10"
}

data "external" "unflatten_configuration" {
  program = ["python3", "${path.module}/python/unflatten_map.py", jsonencode(var.flat_configuration), var.prefix]
}

locals {
  unflattened_configuration = jsondecode(data.external.unflatten_configuration.result["result"])
}