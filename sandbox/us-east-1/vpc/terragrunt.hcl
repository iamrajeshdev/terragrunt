include "root" {
  path = find_in_parent_folders()
}

locals {
  config = yamldecode(file(find_in_parent_folders("deployment-config.yml")))

  basename_parts = split("/", get_terragrunt_dir())
  environment = basename(local.basename_parts[length(local.basename_parts) - 3])
  region = basename(local.basename_parts[length(local.basename_parts) - 2])
  module_name = basename(local.basename_parts[length(local.basename_parts) - 1])

  module=lookup(local.config.modules, local.module_name, "")

  resource_dir = get_terragrunt_dir()
}

terraform {
  source = format("%s?ref=%s", local.module.git_source, local.module.git_version)
}

inputs = merge(
  local.config,
  {
    terraform_path = path_relative_to_include()
    vpc_index = 0
    environment = local.environment
    primary_cidr_block = "10.0.0.0/16"
  }
)