
terraform {
  source = "./terraform"
}

include "root" {
  path = find_in_parent_folders("root.hcl")
}

dependency "provision" {
  config_path = "../bootstrap"
}

inputs = {
  kubeconfig_path = dependency.provision.outputs.kubeconfig_path
}