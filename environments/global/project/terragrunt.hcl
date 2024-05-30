include "parent" {
  path   = find_in_parent_folders()
  expose = true
}

terraform {
  source = "${include.parent.locals.source}/tf-gcp-project"
}

inputs = {
  project_id   = include.parent.locals.project
  region       = include.parent.locals.region
  project_name = "Abby Ranson Portfolio"

  # Billing and budget configuration
  billing_account = include.parent.locals.billing_account
  budget_name     = "portfolio-billing"
  budget_amount   = "20"
  budget_topic    = "budget_monitor"

  labels = {
    "firebase" = "enabled"
  }
}