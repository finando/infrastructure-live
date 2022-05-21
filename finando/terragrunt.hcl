remote_state {
  backend = "s3"

  config = {
    encrypt        = true
    bucket         = "finando-terraform-state"
    key            = "${path_relative_to_include()}/terraform.tfstate"
    region         = "eu-north-1"
    dynamodb_table = "finando-terraform-locks"
    profile        = "terragrunt@finando"
  }
}
