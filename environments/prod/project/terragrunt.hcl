include "parent" {
  path   = find_in_parent_folders()
  expose = true
}

terraform {
  source = "git@github.com:ranson21/tf-gcp-project"
}

inputs = {
  billing_account = include.parent.locals.billing_account
  project_id      = include.parent.locals.project
  region          = include.parent.locals.region
  project_name    = "Abby Ranson Portfolio"
}