variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "configuration_add_on" {
  description = "List of dictionaries configuration for testing"
  type        = any
  default     = {}
}

variable "prefix" {
  description = "Prefix for SSM parameters"
  type        = string
  default     = "/test"
}