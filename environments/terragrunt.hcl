locals {
  bucket_name     = get_env("TF_STATE_BUCKET", "ranson-terraform")
  project         = get_env("GCP_PROJECT", "abby-ranson")
  region          = get_env("REGION", "us-central1")
  billing_account = get_env("BILLING_ACCOUNT", "abbyranson.com")
}

remote_state {
  backend = "gcs"
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite"
  }
  config = {
    bucket = "${local.bucket_name}"
    prefix = "${path_relative_to_include()}"
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
      version = "4.53.1"
    }
  }
}

provider "google" {
  project = "${local.project}"
  region  = "${local.region}"
}
EOF
}