locals {
  public_ip  = "10.10.10.0/24"
  private_ip = "10.10.20.0/24"
  db_ip      = "10.10.30.0/24"
}

include "parent" {
  path   = find_in_parent_folders()
  expose = true
}

terraform {
  source = "git@github.com:terraform-google-modules/terraform-google-network?ref=v9.1.0"
}

inputs = {
  project_id                             = dependency.project.outputs.project
  network_name                           = "${dependency.project.outputs.project}-vpc"
  delete_default_internet_gateway_routes = true

  subnets = [
    {
      subnet_name   = "public-subnet"
      subnet_ip     = local.public_ip
      subnet_region = include.parent.locals.region
      description   = "Public network layer for internet traffic"
    },
    {
      subnet_name           = "private-subnet"
      subnet_ip             = local.private_ip
      subnet_region         = include.parent.locals.region
      subnet_private_access = "true"
      subnet_flow_logs      = "true"
      description           = "Application network layer for API services"
    },
    {
      subnet_name           = "db-subnet"
      subnet_ip             = local.db_ip
      subnet_region         = include.parent.locals.region
      subnet_private_access = "true"
      subnet_flow_logs      = "true"
      description           = "Database network layer for data services"
    }
  ]

  ingress_rules = [
    {
      name               = "tcp-private-db-deny"
      source_ranges      = ["0.0.0.0/0"]
      destination_ranges = [local.private_ip, local.db_ip]
      deny = [{
        protocol = "tcp"
        ports    = ["0-65535"]
      }]
    },
    {
      name               = "tcp-private-ingress-allow"
      source_ranges      = [local.public_ip]
      destination_ranges = [local.private_ip]
      allow = [{
        protocol = "tcp"
        ports    = ["0-65535"]
      }]
    },
    {
      name               = "tcp-db-ingress-allow"
      source_ranges      = [local.private_ip]
      destination_ranges = [local.db_ip]
      allow = [{
        protocol = "tcp"
        ports    = ["0-65535"]
      }]
    },
    {
      name               = "tcp-public-ingress-allow"
      source_ranges      = ["0.0.0.0/0"]
      destination_ranges = [local.public_ip]
      allow = [
        {
          protocol = "icmp"
        },
        {
          protocol = "tcp"
          ports    = ["443"]
      }]
    }
  ]
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