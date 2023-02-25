include "parent" {
  path = find_in_parent_folders()
  expose = true
}

terraform {
  source = "git@github.com:ranson21/tf-gcp-dns"
}

inputs = {
}