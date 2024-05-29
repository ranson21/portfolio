include "parent" {
  path   = find_in_parent_folders()
  expose = true
}

terraform {
  source = "git@github.com:ranson21/tf-gcp-lb"
  // source = "${get_parent_terragrunt_dir()}/..//assets/modules/tf-gcp-lb"
}

inputs = {
  name    = "${include.parent.locals.project}-lb"
  project = dependency.project.outputs.project
  domain  = dependency.dns.outputs.dns_name
  url_map = dependency.cdn.outputs.url_map
  network = dependency.dns.outputs.name
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
  config_path = "../../global/project"
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
  config_path = "../../global/gcp-apis"
  mock_outputs_allowed_terraform_commands = [
    "init",
    "validate",
    "plan",
  ]
  mock_outputs = {
  }
}