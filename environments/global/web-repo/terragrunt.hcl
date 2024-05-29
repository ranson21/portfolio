include "parent" {
  path   = find_in_parent_folders()
  expose = true
}

terraform {
  source = "git@github.com:mineiros-io/terraform-github-repository"
}

inputs = {
  name = "portfolio-web"
}