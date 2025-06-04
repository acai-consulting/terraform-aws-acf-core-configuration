output "test_success" {
  description = "Indicates if the test was successful"
  value = can(module.core_configuration_reader.configuration_output) ? "true" : "false"
}

output "configuration_output" {
  description = "The configuration that was read back"
  value = try(module.core_configuration_reader.configuration_output, {})
}

output "dict_list_test" {
  description = "Test dictionary list handling"
  value = can(lookup(module.core_configuration_reader.configuration_output, "dict_list", [])) ? "true" : "false"
}

output "mixed_structure_test" {
  description = "Test mixed structure handling"
  value = can(lookup(module.core_configuration_reader.configuration_output, "mixed_structure", {})) ? "true" : "false"
}