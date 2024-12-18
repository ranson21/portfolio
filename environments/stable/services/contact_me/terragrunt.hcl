include "parent" {
  path   = find_in_parent_folders()
  expose = true
}
locals {
  # Get latest release version using GitHub API
  latest_version = run_cmd("--terragrunt-quiet",
    "sh", "-c",
    "curl -s -H 'Authorization: token ${get_env("GITHUB_TOKEN")}' https://api.github.com/repos/ranson21/cloud-functions/releases/latest | grep tag_name | cut -d '\"' -f 4"
  )


  # Read the current version from the state if it exists
  current_version = try(
    run_cmd("--terragrunt-quiet",
      "sh", "-c",
      "terraform output -raw deployed_version 2>/dev/null || echo 'none'"
    ),
    "none"
  )
}

terraform {
  source = "${include.parent.locals.source}/tf-gcp-cloudfunction"

  before_hook "show_version_change" {
    commands = ["plan", "apply"]
    execute = [
      "sh", "-c",
      "echo \"Version change detected: ${local.current_version} -> ${local.latest_version}\""
    ]
  }

  before_hook "check_vars" {
    commands = ["init", "plan", "apply"]
    execute = [
      "sh", "-c",
      "if [ -z \"$GITHUB_TOKEN\" ]; then echo 'Error: GITHUB_TOKEN environment variable is required' >&2; exit 1; fi"
    ]
  }
}

inputs = {
  name        = "contact-me"
  runtime     = "python39"
  description = "Function to contact me from portfolio"
  bucket      = "ranson-cloud-functions"
  path        = "${local.latest_version}/python/contact_me.zip"
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