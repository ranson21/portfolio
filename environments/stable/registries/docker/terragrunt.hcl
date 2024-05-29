include "parent" {
  path   = find_in_parent_folders()
  expose = true
}

terraform {
  source = "${include.parent.locals.source}/tf-gcp-artifact-registry"
}

inputs = {
  name = "docker"
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