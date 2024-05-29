include "parent" {
  path   = find_in_parent_folders()
  expose = true
}

terraform {
  source = "${include.parent.locals.source}/tf-gcp-cdn"
}

inputs = {
  name         = "${include.parent.locals.project}-cdn"
  bucket_name  = dependency.dns.outputs.dns_name
  region       = include.parent.locals.region
  domain       = include.parent.locals.domain
  url_map_name = "${include.parent.locals.project}-lb"
}

dependency "dns" {
  config_path = "../../stable/dns-public"
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