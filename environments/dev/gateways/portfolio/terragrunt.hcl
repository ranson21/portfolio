locals {
  site_name = "abbyranson"
}

include "parent" {
  path   = find_in_parent_folders()
  expose = true
}

terraform {
  source = "${include.parent.locals.source}/tf-gcp-lb"
}

inputs = {
  project = dependency.project.outputs.project
  name    = "${include.parent.locals.project}-lb"

  ssl     = true
  domains = [include.parent.locals.domain]

  # Configure the static website backend bucket
  backend_buckets = {
    static = {
      bucket_name = include.parent.locals.domain
      enable_cdn  = true
      description = "Static website bucket backend"
      cdn_policy = {
        cache_mode        = "CACHE_ALL_STATIC"
        default_ttl       = 3600
        client_ttl        = 3600
        max_ttl           = 86400
        negative_caching  = true
        serve_while_stale = 86400
      }
    }
  }

  # Add backend services configuration
  backend_services = {
    contact = {
      protocol     = "HTTPS"
      port_name    = "http"
      enable_cdn   = false
      description  = "Contact form API backend"
      port         = 443              # Added required port
      backend_type = "SERVERLESS_NEG" # Added required backend_type
      backends = [{
        group           = dependency.contact_function.outputs.serverless_neg_id
        balancing_mode  = "UTILIZATION"
        capacity_scaler = 1.0
      }]
    }
  }


  # URL map configuration
  url_map_config = {
    default_service = "static"
    host_rules = [{
      hosts        = [include.parent.locals.domain]
      path_matcher = local.site_name
    }]
    path_matchers = [{
      name            = local.site_name
      default_service = "static"
      path_rules = [{
        paths   = ["/api/contact/*", "/api/contact"] # Added wildcard and exact match
        service = "contact"
      }]
    }]
  }
}


dependency "contact_function" {
  config_path                             = "../../services/contact_me"
  mock_outputs_allowed_terraform_commands = ["init", "validate", "plan"]
  mock_outputs = {
    serverless_neg_id = ""
  }
}

dependency "storage" {
  config_path                             = "../../web/bucket"
  mock_outputs_allowed_terraform_commands = ["init", "validate", "plan"]
  mock_outputs = {
    bucket_name = ""
  }
}

# dependency "api_service" {
#   config_path = "../api"
#   mock_outputs_allowed_terraform_commands = ["init", "validate", "plan"]
#   mock_outputs = {
#     serverless_neg_id = ""
#   }
# }

dependency "project" {
  config_path                             = "../../../global/project"
  mock_outputs_allowed_terraform_commands = ["init", "validate", "plan", "import"]
  mock_outputs = {
    project = ""
  }
}

dependency "apis" {
  config_path                             = "../../../global/gcp-apis"
  mock_outputs_allowed_terraform_commands = ["init", "validate", "plan"]
  mock_outputs = {
  }
}