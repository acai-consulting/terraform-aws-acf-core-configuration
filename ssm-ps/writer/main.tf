# ---------------------------------------------------------------------------------------------------------------------
# ¦ REQUIREMENTS
# ---------------------------------------------------------------------------------------------------------------------
terraform {
  required_version = ">= 1.3.10"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0"
      configuration_aliases = [
        aws.ssm_ps_writer
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

locals {
  flattened_configuration_add_on = module.complex_map_to_simple_map.flattened_configuration_add_on
}

# ---------------------------------------------------------------------------------------------------------------------
# ¦ STORE CONFIGURATION
# ---------------------------------------------------------------------------------------------------------------------
# Resource to use when NOT overwriting parameters (ignore changes)
resource "aws_ssm_parameter" "ssm_parameters_ignore" {
  for_each = var.parameters_overwrite ? {} : local.flattened_configuration_add_on

  name     = each.key
  type     = "String"
  value    = each.value
  tags     = var.resource_tags
  provider = aws.ssm_ps_writer

  lifecycle {
    ignore_changes = [value, tags]
  }
  depends_on = [module.complex_map_to_simple_map]
}

# Resource to use when overwriting parameters (do not ignore changes)
resource "aws_ssm_parameter" "ssm_parameters_overwrite" {
  for_each = var.parameters_overwrite ? local.flattened_configuration_add_on : {}

  name       = each.key
  type       = "String"
  value      = each.value
  tags       = var.resource_tags
  overwrite  = true
  provider   = aws.ssm_ps_writer
  depends_on = [module.complex_map_to_simple_map]
}
