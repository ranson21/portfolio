include "parent" {
  path = find_in_parent_folders()
}

terraform {
  source = "git@github.com:ranson21/tf-gcp-vpc"
}

inputs = {
  project = dependency.project.outputs.project
  name    = "${dependency.project.outputs.project}-vpc"
  source_ranges = [
    "0.0.0.0/0",
  ]
}

dependency "project" {
  config_path = "../project"
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
  config_path = "../gcp-apis"
  mock_outputs_allowed_terraform_commands = [
    "init",
    "validate",
    "plan",
  ]
  mock_outputs = {
  }
}