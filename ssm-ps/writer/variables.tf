variable "configuration_add_on" {
  description = "Complex map of configuration add-on."
  type        = any
}

variable "parameters_overwrite" {
  description = "Overwrite existing Parmeter Store entries."
  type        = bool
  default     = false
}

variable "parameter_name_prefix" {
  description = "Prefix the SSM Parameter Store entries shall have (to cluster them)."
  type        = string
  default     = "/foundation"
}

# ---------------------------------------------------------------------------------------------------------------------
# ¦ COMMON
# ---------------------------------------------------------------------------------------------------------------------
variable "resource_tags" {
  description = "A map of tags to assign to the resources in this module."
  type        = map(string)
  default     = {}
}
