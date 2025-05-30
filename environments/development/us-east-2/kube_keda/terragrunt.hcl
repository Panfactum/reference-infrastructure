include "panfactum" {
  path   = find_in_parent_folders("panfactum.hcl")
  expose = true
}

terraform {
  source = include.panfactum.locals.pf_stack_source
}

dependency "cert_issuers" {
  config_path  = "../kube_certificates"
  skip_outputs = true
}

dependency "scheduler" {
  config_path  = "../kube_scheduler"
  skip_outputs = true
}

inputs = {}
