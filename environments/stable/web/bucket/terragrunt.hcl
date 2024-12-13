# storage/terragrunt.hcl

include "parent" {
  path   = find_in_parent_folders()
  expose = true
}

terraform {
  source = "git@github.com:terraform-google-modules/terraform-google-cloud-storage?ref=v5.0.0"
}

locals {
  # Use the domain name from parent locals for the bucket name
  bucket_name = include.parent.locals.domain
}

inputs = {
  project_id = dependency.project.outputs.project
  names      = [local.bucket_name] # Using domain name as bucket name
  prefix     = ""

  # Configure the bucket for website hosting
  website = {
    main_page_suffix = "index.html"
    not_found_page   = "404.html"
  }

  # Make the bucket publicly readable
  public_access_prevention = "enforced"
  iam_members = [{
    role   = "roles/storage.objectViewer"
    member = "allUsers"
  }]

  # Configure CORS for web assets
  cors = [{
    origin          = [include.parent.locals.domain]
    method          = ["GET", "HEAD", "OPTIONS"]
    response_header = ["*"]
    max_age_seconds = 3600
  }]

  storage_class = "STANDARD"

  force_destroy = {
    "${local.bucket_name}" = true
  }

  versioning = {
    "${local.bucket_name}" = false
  }

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
