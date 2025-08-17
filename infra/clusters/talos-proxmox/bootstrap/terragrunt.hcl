include {
  path = find_in_parent_folders("terragrunt.stack.hcl")
}

terraform {
  source = "./terraform"
}

inputs = {
  # Pass all relevant inputs from stack (env_config)
  virtual_environment_password     = local.virtual_environment_password
  virtual_environment_endpoint     = local.virtual_environment_endpoint
  virtual_environment_username     = local.virtual_environment_username
  virtual_environment_node_name    = local.virtual_environment_node_name
  virtual_environment_datastore_id = local.virtual_environment_datastore_id
  project_name      = local.project_name
  vm_username       = local.vm_username
  vm_count          = local.vm_count
  priv_key_path     = local.priv_key_path
  public_key_path   = local.public_key_path
  image_url         = local.image_url
  # Add bootstrap-specific variables here if needed
  controlplane_ip = dependency.provision.outputs.controlplane_ip
  worker_ips      = dependency.provision.outputs.worker_ips
}

dependency "provision" {
  config_path = "../provision"
  mock_outputs = {
    controlplane_ip = "0.0.0.0"
    worker_ips      = ["0.0.0.0"]
  }
}
