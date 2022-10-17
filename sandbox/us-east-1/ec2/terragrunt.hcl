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

dependency "vpc" {
  config_path = format("../vpc")

  mock_outputs_allowed_terraform_commands = ["plan", "validate"]
  mock_outputs = {
    vpc_name = "test_vpc_name"
    vpc_id = "vpc_testid1234"
  }
}


inputs = merge(
  local.config,
  {
    terraform_path = path_relative_to_include()
    environment = local.environment
    vpc_name = dependency.vpc.outputs.vpc_name
    vpc_id = dependency.vpc.outputs.vpc_id
    ami = "ami-026b57f3c383c2eec"
    itype = "t2.micro"
  }
)