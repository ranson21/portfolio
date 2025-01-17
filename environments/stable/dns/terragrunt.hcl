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
    "${include.parent.locals.domain}"     = "199.36.158.100"
    "vpn.${include.parent.locals.domain}" = dependency.vpn_server.outputs.vpn_server_ip
  }

  txt_records = {
    "${include.parent.locals.domain}" = "\"hosting-site=abby-ranson\""
    "_acme-challenge.abbyranson.com"  = get_env("ACME_CHALLENGE_TOKEN")
  }
}

dependency "vpn_server" {
  config_path = "../vpn"
  mock_outputs_allowed_terraform_commands = [
    "init",
    "validate",
    "plan",
  ]
  mock_outputs = {
    vpn_server_ip = ""
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