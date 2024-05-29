locals {
  version_number = "1.0.0"
  version        = "release-${local.version_number}"
}

include "parent" {
  path   = find_in_parent_folders()
  expose = true
}

terraform {
  source = "${include.parent.locals.source}/tf-web-deployer"
}

inputs = {
  release_version = "${local.version}"
  owner           = "ranson21"
  repo            = "portfolio-web"
  bucket_name     = dependency.dns.outputs.dns_name
}

dependency "cdn" {
  config_path = "../web-cdn"
  mock_outputs_allowed_terraform_commands = [
    "init",
    "validate",
    "plan",
  ]
  mock_outputs = {
  }
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