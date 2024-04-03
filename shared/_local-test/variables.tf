variable "configuration_add_on" {
  description = "Complex map of configuration add-on."
  type        = any
}

variable "prefix" {
  description = "Prefix to the configuration-item keys."
  type        = string
  default     = "/foundation"
}