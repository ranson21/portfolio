include "parent" {
  path   = find_in_parent_folders()
  expose = true
}

terraform {
  source = "${include.parent.locals.source}/tf-gcp-cloud-run"
}

inputs = {
  name    = "test-svc"
  region  = include.parent.locals.region
  project = dependency.project.outputs.project
  // image   = "${include.parent.locals.image_base}/tmpl-nodejs-express"
  image   = "gcr.io/cloudrun/hello"
  network = dependency.vpc.outputs.network_name
  subnet  = "private-subnet"
}


dependency "vpc" {
  config_path = "../../vpc"
  mock_outputs_allowed_terraform_commands = [
    "init",
    "validate",
    "plan",
  ]
  mock_outputs = {
    dns_name = ""
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