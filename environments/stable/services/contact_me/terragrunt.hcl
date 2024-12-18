include "parent" {
  path   = find_in_parent_folders()
  expose = true
}

terraform {
  source = "${include.parent.locals.source}/tf-gcp-cloudfunction"
}

inputs = {
  name        = "contact-me"
  runtime     = "python39"
  description = "Function to contact me from portfolio"
  bucket      = "ranson-cloud-functions"
  path        = "python/contact_me.zip"
  entrypoint  = "contact_me"
  region      = include.parent.locals.region
  # network_name = "${dependency.project.outputs.project}-vpc"


  env_vars = {
    GCP_PROJECT       = dependency.project.outputs.project
    SLACK_WEBHOOK_URL = "sm://projects/${dependency.project.outputs.project}/secrets/slack_webhook_url/versions/latest"
  }
}

dependency "project" {
  config_path = "../../../global/project"
  mock_outputs_allowed_terraform_commands = [
    "init",
    "validate",
    "plan",
  ]
  mock_outputs = {
    project = ""
  }
}