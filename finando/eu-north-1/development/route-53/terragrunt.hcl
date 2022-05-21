terraform {
  source = "git@github.com:finando/infrastructure-modules.git//route-53?ref=route-53-1.0.0"
}

include {
  path = find_in_parent_folders()
}

inputs = {
  common      = yamldecode(file(find_in_parent_folders("common.yml")))
  account     = yamldecode(file(find_in_parent_folders("account.yml")))
  region      = yamldecode(file(find_in_parent_folders("region.yml")))
  environment = yamldecode(file(find_in_parent_folders("environment.yml")))
}
