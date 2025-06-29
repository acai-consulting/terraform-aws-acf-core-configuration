# ---------------------------------------------------------------------------------------------------------------------
# ¦ PROVIDER
# ---------------------------------------------------------------------------------------------------------------------
provider "aws" {
  region = "eu-central-1"
  assume_role {
    role_arn = "arn:aws:iam::471112796356:role/OrganizationAccountAccessRole"
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# ¦ BACKEND
# ---------------------------------------------------------------------------------------------------------------------
terraform {
  backend "remote" {
    organization = "acai"
    hostname     = "app.terraform.io"

    workspaces {
      name = "aws-testbed"
    }
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# ¦ VERSIONS
# ---------------------------------------------------------------------------------------------------------------------
terraform {
  required_version = ">= 1.3.10"

  required_providers {
    aws = {
      source                = "hashicorp/aws"
      version               = ">= 5.0"
      configuration_aliases = []
    }
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# ¦ DATA
# ---------------------------------------------------------------------------------------------------------------------
data "aws_caller_identity" "current" {}

# ---------------------------------------------------------------------------------------------------------------------
# ¦ LOCALS
# ---------------------------------------------------------------------------------------------------------------------
locals {
  parameter_name_prefix = "/test8"
}

# ---------------------------------------------------------------------------------------------------------------------
# ¦ PROBE
# ---------------------------------------------------------------------------------------------------------------------
resource "aws_iam_role" "example" {
  name = "example-iam-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })
}


# ---------------------------------------------------------------------------------------------------------------------
# ¦ MODULES
# ---------------------------------------------------------------------------------------------------------------------
module "core_configuration_roles" {
  source = "../../ssm-ps/iam-roles"

  trusted_account_ids   = [data.aws_caller_identity.current.account_id]
  parameter_name_prefix = local.parameter_name_prefix
  iam_roles = {
    configuration_reader_role_name = "test-reader"
    configuration_writer_role_name = "test-writer"
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# ¦ LOCALS
# ---------------------------------------------------------------------------------------------------------------------
locals {
  configuration_add_on = {
    iam_role_arn = aws_iam_role.example.arn
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# ¦ CORE CONFIGURATION - WRITER
# ---------------------------------------------------------------------------------------------------------------------
provider "aws" {
  region = "eu-central-1"
  alias  = "core_configuration_writer"
  assume_role {
    role_arn = module.core_configuration_roles.configuration_writer_role_arn
  }
}

module "core_configuration_writer" {
  source = "../../ssm-ps/writer_new"

  configuration_add_on  = local.configuration_add_on
  parameter_overwrite   = true
  parameter_name_prefix = local.parameter_name_prefix
  providers = {
    aws.configuration_writer = aws.core_configuration_writer
  }
  depends_on = [
    module.core_configuration_roles
  ]
}

# ---------------------------------------------------------------------------------------------------------------------
# ¦ CORE CONFIGURATION - READER
# ---------------------------------------------------------------------------------------------------------------------
provider "aws" {
  region = "eu-central-1"
  alias  = "core_configuration_reader"
  assume_role {
    role_arn = module.core_configuration_roles.configuration_reader_role_arn
  }
}

module "core_configuration_reader" {
  source = "../../ssm-ps/reader"

  parameter_name_prefix = local.parameter_name_prefix
  providers = {
    aws.configuration_reader = aws.core_configuration_reader
  }
  depends_on = [
    module.core_configuration_roles,
    module.core_configuration_writer
  ]
}
