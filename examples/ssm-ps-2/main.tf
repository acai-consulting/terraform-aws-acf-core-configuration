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
  configuration_add_on1 = {
    addon1_l1_e1_item = "value addon1_l1_e1_item"
    addon1_l1_e2_item = "value addon1_l1_e3_item"
    addon1_l1_e3_node = {
      addon1_l1_e3_l2_e1_item = "value addon1_l1_e3_l2_e1_item"
      addon1_l1_e3_l2_e2_node = {
        addon1_l1_e3_l2_e2_l3_e1_item = "value addon1_l1_e3_l2_e2_l3_e1_item"
        addon1_l1_e3_l2_e2_l3_e2_item = "value addon1_l1_e3_l2_e2_l3_e2_item"
        addon1_l1_e3_l2_e2_l3_e3_node = {
          addon1_l1_e3_l2_e2_l3_e3_l4_e1_item = "value addon1_l1_e3_l2_e2_l3_e3_l4_e1_item"
          addon1_l1_e3_l2_e2_l3_e3_l4_e2_item = "value addon1_l1_e3_l2_e2_l3_e3_l4_e2_item"
        }
      }
    }
  }
  configuration_add_on2 = {
    addon2_l1_e1_item = "value addon2_l1_e1_item"
    addon2_l1_e2_item = "value addon2_l1_e3_item"
  }

  parameter_name_prefix = "/test2"

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

  configuration_add_on_list = [
    local.configuration_add_on1,
    local.configuration_add_on2
  ]
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
    module.core_configuration_writer,
  ]
}

