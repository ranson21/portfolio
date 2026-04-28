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
    "${include.parent.locals.domain}" = "199.36.158.100"
  }

  txt_records = {
    "${include.parent.locals.domain}" = "\"hosting-site=abby-ranson\""
    "_acme-challenge.abbyranson.com"  = get_env("ACME_CHALLENGE_TOKEN")
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