include "parent" {
  path = find_in_parent_folders()
}

terraform {
  source = "git@github.com:ranson21/tf-gcp-dns"
}

inputs = {
  zone_name = "public-dns"
  domain    = "abbyranson.com"
  project   = dependency.project.outputs.project
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