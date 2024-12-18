include "parent" {
  path   = find_in_parent_folders()
  expose = true
}

terraform {
  source = "${include.parent.locals.source}/tf-gcp-secret"
}

inputs = {
  project = dependency.project.outputs.project
  secrets = {
    github_token      = get_env("GITHUB_TOKEN")
    slack_webhook_url = get_env("SLACK_WEBHOOK_URL")
  }
}

dependency "project" {
  config_path = "../project"
  mock_outputs_allowed_terraform_commands = [
    "init",
    "validate",
    "plan",
  ]
  mock_outputs = {
    project = ""
  }
}