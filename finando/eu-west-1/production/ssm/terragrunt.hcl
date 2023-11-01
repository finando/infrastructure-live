terraform {
  source = "git@github.com:finando/infrastructure-modules.git//packages/ssm?ref=ssm@0.2.1"
}

include {
  path = find_in_parent_folders()
}

locals {
  common      = yamldecode(file(find_in_parent_folders("common.yml")))
  account     = yamldecode(file(find_in_parent_folders("account.yml")))
  region      = yamldecode(file(find_in_parent_folders("region.yml")))
  environment = yamldecode(file(find_in_parent_folders("environment.yml")))
  namespace   = "${local.common.project.name}-${local.region.name}-${local.environment.name}"
  tags        = merge(local.account.tags, local.region.tags, local.environment.tags)
  vars        = jsondecode(read_tfvars_file("terraform.tfvars"))
}

inputs = {
  common      = local.common
  account     = local.account
  region      = local.region
  environment = local.environment
  namespace   = local.namespace
  tags        = local.tags

  ssm_parameters = {
    ses_configuration = {
      name        = "${local.namespace}-ses-configuration"
      description = "SES configuration parameters (formatted as JSON)"
      type        = "SecureString"
      value       = jsonencode(local.vars.ssm_parameter_values.ses_configuration)
    }
    ses_smtp_users = {
      name        = "${local.namespace}-ses-smtp-users"
      description = "An array of SES SMTP users (formatted as JSON)"
      type        = "SecureString"
      value       = jsonencode(local.vars.ssm_parameter_values.ses_smtp_users)
    }
  }
}
