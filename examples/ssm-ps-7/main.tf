# ---------------------------------------------------------------------------------------------------------------------
# ¦ PROVIDER
# ---------------------------------------------------------------------------------------------------------------------
provider "aws" {
  region = "eu-central-1"
  # please use the target role you need.
  # create additional providers in case your module provisions to multiple core accounts.
  assume_role {
    role_arn = "arn:aws:iam::471112796356:role/OrganizationAccountAccessRole" // ACAI AWS Testbed Org-Mgmt Account
    #role_arn = "arn:aws:iam::590183833356:role/OrganizationAccountAccessRole" // ACAI AWS Testbed Core Logging Account
    #role_arn = "arn:aws:iam::992382728088:role/OrganizationAccountAccessRole" // ACAI AWS Testbed Core Security Account
    #role_arn = "arn:aws:iam::767398146370:role/OrganizationAccountAccessRole" // ACAI AWS Testbed Workload Account
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
  configuration_add_on = {
    simple_string = "test_value"
    dict_list = [
      {
        name    = "dict1"
        value   = "value1"
        enabled = "true"
      },
      {
        name    = "dict2"
        value   = "value2"
        enabled = "false"
        nested = {
          sub_key = "sub_value"
        }
      }
    ]
    mixed_structure = {
      items = [
        {
          id   = "item1"
          tags = ["production", "critical"]
        },
        {
          id   = "item2"
          tags = ["development"]
          config = {
            timeout = "30"
            retry   = "true"
          }
        }
      ]
    }
  }

  parameter_name_prefix = "/test7"

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
  source = "../../ssm-ps/writer"

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

