variable "configuration_add_on" {
  description = "Complex map of configuration add-on."
  type        = any
  default     = {}
}

variable "configuration_add_on_list" {
  description = "List of complex maps for configuration add-ons."
  type        = any
  default     = []

  validation {
    condition     = can(length(var.configuration_add_on_list)) || can(var.configuration_add_on_list[0])
    error_message = "The configuration_add_on_list must be a list."
  }
}

variable "parameter_overwrite" {
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
