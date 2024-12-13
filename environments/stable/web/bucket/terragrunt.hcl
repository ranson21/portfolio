# storage/terragrunt.hcl

include "parent" {
  path   = find_in_parent_folders()
  expose = true
}

terraform {
  source = "${include.parent.locals.source}/tf-gcp-bucket"
}

locals {
  # Use the domain name from parent locals for the bucket name
  bucket_name = include.parent.locals.domain
}


inputs = {
  project_id        = dependency.project.outputs.project
  bucket_name       = local.bucket_name
  location          = "US"
  storage_class     = "STANDARD"
  force_destroy     = true
  enable_versioning = false

  website_config = {
    main_page_suffix = "index.html"
    not_found_page   = "404.html"
  }

  cors_rules = [{
    origin          = [include.parent.locals.domain]
    method          = ["GET", "HEAD", "OPTIONS"]
    response_header = ["*"]
    max_age_seconds = 3600
  }]

  lifecycle_rules = [{
    action = {
      type = "Delete"
    }
    condition = {
      age        = 365
      with_state = "ARCHIVED"
    }
  }]
}

dependency "project" {
  config_path                             = "../../../global/project"
  mock_outputs_allowed_terraform_commands = ["init", "validate", "plan", "import"]
  mock_outputs = {
    project = ""
  }
}
