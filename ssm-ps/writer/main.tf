# ---------------------------------------------------------------------------------------------------------------------
# ¦ REQUIREMENTS
# ---------------------------------------------------------------------------------------------------------------------
terraform {
  required_version = ">= 1.3.10"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
      configuration_aliases = [
        aws.configuration_writer
      ]
    }
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# ¦ LOCALS
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
resource "aws_ssm_parameter" "ssm_parameters_ignore" {
  for_each = var.parameter_overwrite ? {} : local.flattened_configuration_add_on

  name     = each.key
  type     = "String"
  value    = each.value
  tags     = var.resource_tags
  provider = aws.configuration_writer

  lifecycle {
    ignore_changes = [value, tags]
  }
  depends_on = [module.complex_map_to_simple_map]
}

# Resource to use when overwriting parameters (do not ignore changes)
resource "aws_ssm_parameter" "ssm_parameters_overwrite" {
  for_each = var.parameter_overwrite ? local.flattened_configuration_add_on : {}

  name       = each.key
  type       = "String"
  value      = each.value
  tags       = var.resource_tags
  overwrite  = true # currently seems to default to false. Will be removed after terraform aws 6.x
  provider   = aws.configuration_writer
  depends_on = [module.complex_map_to_simple_map]
}
