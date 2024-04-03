output "test_success" {
  description = "Are local.configuration_add_on similar to the read configuration?"
  value = merge(
    local.configuration_add_on,
    local.configuration_add_on1,
    local.configuration_add_on2
  ) == module.core_configuration_reader.unflattened_configuration
}

output "core_configuration_reader" {
  description = "Read configuration?"
  value       = module.core_configuration_reader.unflattened_configuration
}
