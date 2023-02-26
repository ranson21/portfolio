include "parent" {
  path   = find_in_parent_folders()
  expose = true
}

terraform {
  source = "git@github.com:ranson21/tf-gcp-cdn"
  // source = "${get_parent_terragrunt_dir()}/..//assets/modules/tf-gcp-cdn"
}

inputs = {
  name        = "${include.parent.locals.project}-cdn"
  bucket_name = dependency.dns.outputs.dns_name
  region      = include.parent.locals.region
  domain      = dependency.dns.outputs.dns_name
  lb_name     = "${include.parent.locals.project}-lb"
}

dependency "dns" {
  config_path = "../dns-public"
  mock_outputs_allowed_terraform_commands = [
    "init",
    "validate",
    "plan",
  ]
  mock_outputs = {
    dns_name = ""
  }
}

dependency "project" {
  config_path = "../project"
  mock_outputs_allowed_terraform_commands = [
    "init",
    "validate",
    "plan",
    "import",
  ]
  mock_outputs = {
    project = ""
  }
}

dependency "apis" {
  config_path = "../gcp-apis"
  mock_outputs_allowed_terraform_commands = [
    "init",
    "validate",
    "plan",
  ]
  mock_outputs = {
  }
}