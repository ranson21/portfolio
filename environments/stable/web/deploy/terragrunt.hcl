# stable/portfolio-web/terragrunt.hcl
include "parent" {
  path   = find_in_parent_folders()
  expose = true
}

locals {
  # Get latest release version using GitHub API
  latest_version = run_cmd("--terragrunt-quiet",
    "sh", "-c",
    "curl -s -H 'Authorization: token ${get_env("GITHUB_TOKEN")}' https://api.github.com/repos/ranson21/portfolio-web/releases/latest | grep tag_name | cut -d '\"' -f 4"
  )


  # Read the current version from the state if it exists
  current_version = try(
    run_cmd("--terragrunt-quiet",
      "sh", "-c",
      "terraform output -raw deployed_version 2>/dev/null || echo 'none'"
    ),
    "none"
  )
}


# Main terraform block
terraform {
  source = "${include.parent.locals.source}/tf-web-deployer"

  # This forces Terragrunt to show the version change in the plan
  extra_arguments "show_version" {
    commands = ["plan", "apply"]
    arguments = [
      "-replace=null_resource.web_deployer"
    ]
  }

  before_hook "show_version_change" {
    commands = ["plan", "apply"]
    execute = [
      "sh", "-c",
      "echo \"Version change detected: ${local.current_version} -> ${local.latest_version}\""
    ]
  }

  before_hook "check_vars" {
    commands = ["init", "plan", "apply"]
    execute = [
      "sh", "-c",
      "if [ -z \"$GITHUB_TOKEN\" ]; then echo 'Error: GITHUB_TOKEN environment variable is required' >&2; exit 1; fi"
    ]
  }
}

# Force replacement of the null_resource when version changes
inputs = {
  owner           = "ranson21"
  repo            = "portfolio-web"
  release_version = local.latest_version
  asset_name      = "release.tar.gz"
  bucket_name     = "abbyranson.com"

  # Add triggers to force updates when version changes
  triggers = {
    version = local.latest_version
  }
}
