locals {
  name   = split("repos/", get_terragrunt_dir())[1]
  labels = yamldecode(file(find_in_parent_folders("global/repos/labels.yaml")))
}

include "parent" {
  path   = find_in_parent_folders()
  expose = true
}

terraform {
  source = "git@github.com:mineiros-io/terraform-github-repository"
}

inputs = {
  name       = local.name
  visibility = "public"

  issue_labels = local.labels

  # Branch protection for master/main
  branch_protections_v4 = [
    {
      pattern                         = "master"
      enforce_admins                  = false
      require_conversation_resolution = true

      required_status_checks = {
        strict   = true
        contexts = ["check-labels"] # Changed from 'checks' to 'contexts'
      }

      required_pull_request_reviews = {
        dismiss_stale_reviews      = true
        require_code_owner_reviews = true
      }
    }
  ]
}