output "test_success" {
  description = "Indicates if the test was successful"
  value = can(module.core_configuration_reader.configuration_output) ? "true" : "false"
}

output "configuration_output" {
  description = "The configuration that was read back"
  value = try(module.core_configuration_reader.configuration_output, {})
}

output "complex_structure_test" {
  description = "Test complex nested structures"
  value = can(lookup(module.core_configuration_reader.configuration_output, "database", {})) ? "true" : "false"
}