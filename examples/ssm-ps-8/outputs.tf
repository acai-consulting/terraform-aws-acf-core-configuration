output "test_success" {
  description = "Is aws_iam_role.example.arn similar to the read configuration?"
  value       = aws_iam_role.example.arn == module.core_configuration_reader.unflattened_configuration.iam_role_arn

}

output "core_configuration_reader" {
  description = "Read configuration"
  value       = module.core_configuration_reader.unflattened_configuration
}
