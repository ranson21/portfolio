include "parent" {
  path   = find_in_parent_folders()
  expose = true
}

terraform {
  source = "${include.parent.locals.source}/tf-gcp-ovpn"
}

locals {
  iap_client_id = "967775365487-smam5ghl9du51u04sm2sm4tavtkcdd9m"
}

inputs = {
  project_id     = dependency.project.outputs.project
  support_email  = "abby@abbyranson.com"
  client_id      = "${local.iap_client_id}.apps.googleusercontent.com" # Public OAuth 2.0 client ID for IAP
  domain_name    = "vpn.${include.parent.locals.domain}"
  allowed_domain = include.parent.locals.domain

  subnet_cidr   = "10.0.0.0/24" # Adjust as needed
  portal_title  = "VPN Portal"
  region        = include.parent.locals.region
  network_name  = "vpn-network"
  instance_type = "e2-micro"
  disk_size_gb  = 30
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