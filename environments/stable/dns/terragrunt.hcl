include "parent" {
  path   = find_in_parent_folders()
  expose = true
}

terraform {
  source = "${include.parent.locals.source}/tf-gcp-dns"
}

inputs = {
  zone_name = "public-dns"
  domain    = include.parent.locals.domain
  project   = dependency.project.outputs.project

  records = {
    "${include.parent.locals.domain}" = dependency.portfolio-lb.outputs.external_ip
  }
}

dependency "portfolio-lb" {
  config_path = "../gateways/portfolio"
  mock_outputs_allowed_terraform_commands = [
    "init",
    "validate",
    "plan",
  ]
  mock_outputs = {
    external_ip = ""
  }
}

dependency "project" {
  config_path = "../../global/project"
  mock_outputs_allowed_terraform_commands = [
    "init",
    "validate",
    "plan",
  ]
  mock_outputs = {
    project = ""
  }
}