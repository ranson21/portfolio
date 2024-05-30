include "parent" {
  path   = find_in_parent_folders()
  expose = true
}

terraform {
  source = "${include.parent.locals.source}/tf-gcp-gh-pipeline"
}

inputs = {
  region          = include.parent.locals.region
  project         = dependency.project.outputs.project
  project_number  = dependency.project.outputs.project_number
  deploy_key_id   = "github_token"
  connection_name = "github"
  installation_id = "51375780"
  repo_owner      = "ranson21"
  repos = [
    "tmpl-nodejs-express",
    "cloud-functions"
  ]
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