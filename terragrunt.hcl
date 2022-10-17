remote_state {
  backend = "s3"
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }
  config = {
    bucket = "rjterraformstate006"

    key = lower(format("tuhhackathon/%s/terraform.tfstate", path_relative_to_include()))
    region         = "us-east-1"
  }
}

generate "provider" {
  path = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents = <<EOF
provider "aws" {
  assume_role {
    role_arn = "arn:aws:iam::509802029116:role/TerragruntAdminRole"
  }
}
EOF
}