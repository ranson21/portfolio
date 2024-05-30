#
# NOTE: There is one manual step of adding the cloud functions to the billing admin
# role which must be done prior to invoking this function.
# See https://cloud.google.com/billing/docs/how-to/notify#configure_service_account_permissions for more details
#
include "parent" {
  path   = find_in_parent_folders()
  expose = true
}

terraform {
  source = "${include.parent.locals.source}/tf-gcp-cloudfunction"
}

inputs = {
  name        = "disable-billing"
  runtime     = "python39"
  description = "Function to disable billing if budget is exceeded"
  bucket      = "ranson-cloud-functions"
  path        = "python/disable-billing.zip"
  entrypoint  = "stop_billing"

  trigger_topic = dependency.project.outputs.budget_topic
  trigger_type  = "google.pubsub.topic.publish"

  env_vars = {
    GCP_PROJECT = dependency.project.outputs.project
  }
}

dependency "project" {
  config_path = "../../project"
  mock_outputs_allowed_terraform_commands = [
    "init",
    "validate",
    "plan",
  ]
  mock_outputs = {
    project = ""
  }
}