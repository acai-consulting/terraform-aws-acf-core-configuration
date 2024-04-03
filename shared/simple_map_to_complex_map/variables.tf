variable "flat_configuration" {
  description = "Flat configuration-map."
  type        = map(string)
}

variable "prefix" {
  description = "Prefix to the configuration-item keys."
  type        = string
  default     = "/foundation"
}