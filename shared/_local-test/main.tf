# ---------------------------------------------------------------------------------------------------------------------
# ¦ REQUIREMENTS
# ---------------------------------------------------------------------------------------------------------------------
terraform {
  required_version = ">= 1.0.0"
}

module "complex_map_to_simple_map" {
  source = "../complex_map_to_simple_map"

  configuration_add_on = var.configuration_add_on
  prefix               = var.prefix
}

locals {
  flattened_configuration_add_on = module.complex_map_to_simple_map.flattened_configuration_add_on
}

module "simple_map_to_complex_map" {
  source = "../simple_map_to_complex_map"

  flat_configuration = local.flattened_configuration_add_on
  prefix             = var.prefix
}

locals {
  unflattened_configuration_add_on = module.simple_map_to_complex_map.unflattened_configuration
}

module "complex_map_to_simple_map2" {
  source = "../complex_map_to_simple_map"

  configuration_add_on = local.unflattened_configuration_add_on
  prefix               = var.prefix
}

locals {
  flattened_configuration_add_on2 = module.complex_map_to_simple_map2.flattened_configuration_add_on
}

module "simple_map_to_complex_map2" {
  source = "../simple_map_to_complex_map"

  flat_configuration = local.flattened_configuration_add_on2
  prefix             = var.prefix
}

locals {
  unflattened_configuration_add_on2 = module.simple_map_to_complex_map2.unflattened_configuration
}
