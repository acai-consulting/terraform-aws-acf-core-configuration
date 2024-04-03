output "configuration_add_on" {
  description = "Provided complex map of configuration add-on."
  value       = var.configuration_add_on
}

output "flattened_configuration_add_on" {
  description = "Flattened configuration add-on."
  value       = local.flattened_configuration_add_on
}

output "unflattened_configuration_add_on" {
  description = "Unflattened configuration add-on."
  value       = local.unflattened_configuration_add_on
}

output "flattened_configuration_add_on2" {
  description = "Flattened configuration add-on."
  value       = local.flattened_configuration_add_on2
}

output "unflattened_configuration_add_on2" {
  description = "Unflattened configuration add-on."
  value       = local.unflattened_configuration_add_on2
}

output "similar" {
  description = "Is the unflattened_configuration_add_on similar to the provided var.configuration_add_on?"
  value       = var.configuration_add_on == local.unflattened_configuration_add_on && local.unflattened_configuration_add_on2 == local.unflattened_configuration_add_on
}