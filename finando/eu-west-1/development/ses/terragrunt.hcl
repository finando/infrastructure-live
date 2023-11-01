terraform {
  source = "git@github.com:finando/infrastructure-modules.git//packages/ses?ref=ses@0.2.1"
}

dependency "ssm" {
  config_path = "../ssm"
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
}

inputs = {
  common      = local.common
  account     = local.account
  region      = local.region
  environment = local.environment
  namespace   = local.namespace
  tags        = local.tags

  ssm_parameter_ses_configuration = dependency.ssm.outputs.ssm_parameter_name["ses_configuration"]
  ssm_parameter_ses_smtp_users    = dependency.ssm.outputs.ssm_parameter_name["ses_smtp_users"]
}
