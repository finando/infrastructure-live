terraform {
  source = "git@github.com:finando/infrastructure-modules.git//packages/cloudfront?ref=cloudfront@0.1.1"
}

dependency "s3" {
  config_path = "../../../global/development/s3"
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

  cloudfront_distributions = [
    {
      name        = "root"
      domain_name = local.environment.project.domain_name
      cache_behaviours = [
        {
          path             = "/build/*"
          type             = "S3"
          target_origin_id = dependency.s3.outputs.s3_bucket_id["landing-page-web"]
        },
        {
          type                = "S3"
          disable_cache       = true
          rewrite_request_url = true
          target_origin_id    = dependency.s3.outputs.s3_bucket_id["landing-page-web"]
        },
      ]
      s3_origins = [
        {
          id            = dependency.s3.outputs.s3_bucket_id["landing-page-web"]
          domain_name   = dependency.s3.outputs.s3_bucket_regional_domain_name["landing-page-web"]
          s3_bucket_id  = dependency.s3.outputs.s3_bucket_id["landing-page-web"]
          s3_bucket_arn = dependency.s3.outputs.s3_bucket_arn["landing-page-web"]
        },
      ]
      custom_error_response = [
        {
          error_code         = 404
          response_code      = 200
          response_page_path = "/redirect.html"
        },
        {
          error_code         = 403
          response_code      = 200
          response_page_path = "/redirect.html"
        }
      ]
    },
  ]
}
