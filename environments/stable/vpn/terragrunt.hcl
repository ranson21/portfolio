include "parent" {
  path   = find_in_parent_folders()
  expose = true
}

terraform {
  source = "${include.parent.locals.source}/tf-gcp-ovpn"
}

inputs = {
  project_id     = dependency.project.outputs.project
  region         = include.parent.locals.region
  network_name   = "vpn-network"
  subnet_cidr    = "10.0.0.0/24" # Adjust as needed
  support_email  = "abby@abbyranson.com"
  portal_title   = "VPN Portal"
  client_id      = get_env("CLIENT_ID", "")
  domain_name    = "vpn.${include.parent.locals.domain}"
  allowed_domain = include.parent.locals.domain
  instance_type  = "e2-micro"
  disk_size_gb   = 30
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