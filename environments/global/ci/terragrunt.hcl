include "parent" {
  path   = find_in_parent_folders()
  expose = true
}

terraform {
  source = "${include.parent.locals.source}/tf-gcp-gh-pipeline"
}

locals {
  # Repositories that have both PR and push triggers
  dual_trigger_repos = [
    "portfolio-web",
    "gcp-ovpn-portal",
    "tmpl-nodejs-express"
  ]

  # Repositories that only have push triggers
  push_trigger_repos = [
    "ansible-openvpn",
    "dev-tools-builder",
    "github-ops-cli",
    "portfolio"
    "cloud-functions",
    "tf-web-deployer",
    "tf-gcp-storage",
    "tf-gcp-secret",
    "tf-gcp-project",
    "tf-gcp-lb",
    "tf-gcp-gh-pipeline",
    "tf-gcp-dns",
    "tf-gcp-cloudfunction",
    "tf-gcp-cloud-run",
    "tf-gcp-artifact-registry",
    "tf-gcp-bucket",
    "tf-gcp-ovpn",
  ]

  # Convert arrays to the required object format
  repos = concat(
    [for repo in local.dual_trigger_repos : {
      name         = repo
      pr_trigger   = true
      push_trigger = true
    }],
    [for repo in local.push_trigger_repos : {
      name         = repo
      pr_trigger   = false
      push_trigger = true
    }]
  )
}

inputs = {
  region          = include.parent.locals.region
  project         = dependency.project.outputs.project
  project_number  = dependency.project.outputs.project_number
  deploy_key_id   = "github_token"
  connection_name = "github"
  installation_id = "51375780"
  repo_owner      = "ranson21"
  repos           = local.repos

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
    "roles/iam.securityAdmin",
    "roles/secretmanager.secretAccessor",
    "roles/secretmanager.viewer",
    "roles/iap.admin",
    "roles/serviceusage.serviceUsageAdmin",
    "roles/oauthconfig.editor"
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