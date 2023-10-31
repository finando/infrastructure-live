terraform {
  source = "git@github.com:finando/infrastructure-modules.git//packages/route-53?ref=route-53@0.5.2"
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

  dns_records = {
    github_organisation = {
      prefix  = "_github-challenge-finando-org"
      type    = "TXT"
      ttl     = "600"
      records = ["e5a55a924c"]
    }
    github_pages = {
      prefix  = "_github-pages-challenge-finando"
      type    = "TXT"
      ttl     = "600"
      records = ["65f4fbb373efa67279f688c02b05f1"]
    }
  }
}
