locals {
  owner           = "ranson21"
  domain          = "abbyranson.com"
  bucket_name     = get_env("TF_STATE_BUCKET", "portfolio-terraform")
  project         = get_env("GCP_PROJECT", "abby-ranson")
  region          = get_env("REGION", "us-central1")
  billing_account = get_env("BILLING_ACCOUNT", "abbyranson.com")
  source          = get_env("TF_LOCAL", "false") == "true" ? "${get_parent_terragrunt_dir()}/..//assets/modules" : "git@github.com:ranson21"
}

remote_state {
  backend = "gcs"
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite"
  }
  config = {
    project  = "${local.project}"
    bucket   = "${local.bucket_name}"
    location = "${local.region}"
    prefix   = "${path_relative_to_include()}"
  }
}

generate "provider" {
  path      = "provider_override.tf"
  if_exists = "overwrite"
  contents  = <<EOF
# Terragrunt Generated Provider Block
terraform {
  required_version = ">= 0.13"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "5.31.1"
    }
    google-beta = {
      source  = "hashicorp/google-beta"
      version = "~> 5.31.1"
    }
    github = {
      source  = "integrations/github"
      version = "~> 5.0"
    }
  }
}

provider "google" {
  project = "${local.project}"
  region  = "${local.region}"
}

provider "github" {
    owner  = "${local.owner}"
}
EOF
}