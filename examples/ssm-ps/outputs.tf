
output "test_success" {
  description = "Are local.configuration_add_on similar to the read configuration?"
  value       = local.configuration_add_on == module.core_configuration_reader.unflattened_configuration
}