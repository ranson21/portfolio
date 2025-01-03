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
    {
      name = "portfolio-web"
    },
    {
      name = "gcp-ovpn-portal"
    },
    {
      name = "tmpl-nodejs-express"
    },
    {
      name         = "cloud-functions"
      pr_trigger   = false # Only create push trigger
      push_trigger = true
    },
    {
      name         = "github-ops-cli"
      pr_trigger   = false # Only create push trigger
      push_trigger = true
    },
    {
      name         = "portfolio"
      pr_trigger   = false # Only create push trigger
      push_trigger = true
    },
  ]
  cloudbuild_roles = [
    "roles/artifactregistry.reader",
    "roles/storage.admin",
    "roles/compute.admin",
    "roles/compute.networkAdmin",
    "roles/compute.securityAdmin",
    "roles/dns.admin",
    "roles/iam.serviceAccountAdmin",
    "roles/iam.serviceAccountUser",
    "roles/cloudfunctions.admin",
    "roles/resourcemanager.projectIamAdmin",
    "roles/iam.securityAdmin"
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