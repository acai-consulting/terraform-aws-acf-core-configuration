# ---------------------------------------------------------------------------------------------------------------------
# ¦ REQUIREMENTS
# ---------------------------------------------------------------------------------------------------------------------
terraform {
  required_version = ">= 1.3.10"
}


# ---------------------------------------------------------------------------------------------------------------------
# ¦ DATA
# ---------------------------------------------------------------------------------------------------------------------
data "aws_region" "current" {}


# ---------------------------------------------------------------------------------------------------------------------
# ¦ LOCALS
# ---------------------------------------------------------------------------------------------------------------------
locals {
  resource_tags = merge(
    var.resource_tags,
    {
      "module_provider" = "ACAI GmbH",
      "module_name"     = "terraform-aws-acf-core-configuration",
      "module_source"   = "github.com/acai-consulting/terraform-aws-acf-core-configuration",
      "module_version"  = /*inject_version_start*/ "1.3.3" /*inject_version_end*/
    }
  )
}


# ---------------------------------------------------------------------------------------------------------------------
# ¦ DATA TRANSFORMATION
# ---------------------------------------------------------------------------------------------------------------------
module "complex_map_to_simple_map" {
  source = "../../shared/complex_map_to_simple_map"

  configuration_add_on = var.configuration_add_on
  prefix               = var.parameter_name_prefix
}

module "complex_maps_to_simple_maps" {
  source   = "../../shared/complex_map_to_simple_map"
  for_each = { for idx, val in var.configuration_add_on_list : idx => val } # Correct iteration over list with indexing

  configuration_add_on = each.value
  prefix               = var.parameter_name_prefix
}

locals {
  flattened_configuration_add_on = merge(
    module.complex_map_to_simple_map.flattened_configuration_add_on,
    merge([for instance in values(module.complex_maps_to_simple_maps) : instance.flattened_configuration_add_on]...)
  )
}


# ---------------------------------------------------------------------------------------------------------------------
# ¦ STORE CONFIGURATION
# ---------------------------------------------------------------------------------------------------------------------
# Resource to use when NOT overwriting parameters (ignore changes)
resource "null_resource" "write_flattened_map_to_ssm" {
  provisioner "local-exec" {
    command = <<EOT
python3 ${path.module}/python/write_to_ssm.py \
  --map '${jsonencode(local.flattened_configuration_add_on)}' \
  --role-arn '${var.configuration_writer_role_arn}' \
  %{if var.kms_key_arn != null}--kms-key-id "${var.kms_key_arn}"%{endif} \
  --tags '${jsonencode(local.resource_tags)}' \
  --parameter_overwrite '${var.parameter_overwrite}'
EOT
    environment = {
      AWS_DEFAULT_REGION = data.aws_region.current.name
    }
  }
}
