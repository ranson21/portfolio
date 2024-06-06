locals {
  site_name = "abbyranson"
}

include "parent" {
  path   = find_in_parent_folders()
  expose = true
}

terraform {
  source = "git@github.com:terraform-google-modules/terraform-google-lb-http?ref=v11.1.0"
}

inputs = {
  name    = "${include.parent.locals.project}-lb"
  project = dependency.project.outputs.project
  // network                         = dependency.vpc.outputs.name
  ssl                             = true
  https_redirect                  = true
  managed_ssl_certificate_domains = [include.parent.locals.domain]
  firewall_networks               = []

  backends = {
    default = {
      description = null
      groups = [
        {
          group = dependency.svc_test.outputs.serverless_neg_id
        }
      ]
      enable_cdn = false

      iap_config = {
        enable = false
      }
      log_config = {
        enable = false
      }
    }
  }
  // url_map = {
  //   name            = "lb-url-map"
  //   default_service = dependency.svc_test.outputs.serverless_neg_id

  //   host_rule = {
  //     hosts        = [dependency.dns.outputs.dns_name]
  //     path_matcher = local.site_name
  //   }

  //   path_matcher = {
  //     name = local.site_name

  //     path_rule = {
  //       paths   = ["/test"]
  //       service = dependency.svc_test.outputs.serverless_neg_id
  //     }
  //   }
  // }
}

dependency "svc_test" {
  config_path = "../../services/test"
  mock_outputs_allowed_terraform_commands = [
    "init",
    "validate",
    "plan",
  ]
  mock_outputs = {
    dns_name = ""
  }
}

dependency "vpc" {
  config_path = "../../vpc"
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
  config_path = "../../../global/project"
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
  config_path = "../../../global/gcp-apis"
  mock_outputs_allowed_terraform_commands = [
    "init",
    "validate",
    "plan",
  ]
  mock_outputs = {
  }
}