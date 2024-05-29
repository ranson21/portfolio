include "parent" {
  path   = find_in_parent_folders()
  expose = true
}

terraform {
  source = "${include.parent.locals.source}/tf-gcp-firebase"
}

inputs = {
  project       = dependency.project.outputs.project
  name          = "${dependency.project.outputs.project}-firebase"
  region        = include.parent.locals.region
  support_email = "abby@abbyranson.com"
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