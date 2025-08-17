# Root Terragrunt configuration for talos-proxmox

locals {
  # Virtual environment object
  virtual_environment_password     = "changeme"
  virtual_environment_endpoint     = "https://proxmox-dev.example.com:8006/api2/json"
  virtual_environment_username     = "root@pam"
  virtual_environment_node_name    = "pve-dev"
  virtual_environment_datastore_id = "local-lvm"

  project_name      = "talos-proxmox-dev"
  vm_username       = "ubuntu"
  vm_count          = 1
  priv_key_path     = "~/.ssh/id_rsa"
  public_key_path   = "~/.ssh/id_rsa.pub"
  image_url         = "https://cloud-images.ubuntu.com/noble/current/noble-server-cloudimg-amd64.img"
}

remote_state {
  backend = "s3"
  config = {
    endpoints = {
      s3 = "http://<minio-host>:<port>" # use web port, not admin
    }
    bucket                      = "<bucket>"
    key                         = "provision/terraform.tfstate"
    region                      = "us-east-1"
    access_key                  = "<access_key>"
    secret_key                  = "<secret_key>"
    skip_credentials_validation = true
    skip_metadata_api_check     = true
    use_path_style              = true
    skip_requesting_account_id  = true
  }
}
