include {
  path = find_in_parent_folders()
}

terraform {
  source = "./terraform"
}

inputs = {
  virtual_environment = {
    password      = local.virtual_environment_password
    endpoint      = local.virtual_environment_endpoint
    username      = local.virtual_environment_username
    node_name     = local.virtual_environment_node_name
    datastore_id  = local.virtual_environment_datastore_id
  }
  project_name      = local.project_name
  vm_username       = local.vm_username
  vm_count          = local.vm_count
  priv_key_path     = local.priv_key_path
  public_key_path   = local.public_key_path
  image_url         = local.image_url
}
