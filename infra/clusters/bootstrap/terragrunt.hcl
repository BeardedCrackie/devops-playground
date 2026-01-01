# Terragrunt configuration for Talos cluster bootstrap phase
# This unit bootstraps the Talos cluster after VMs are provisioned

terraform {
  source = "git::git@github.com:BeardedCrackie/infra-playground.git//infra/talos-proxmox/bootstrap?ref=v0.1.1"
}

# Include root terragrunt configuration if it exists
include "root" {
  path = find_in_parent_folders("terragrunt.hcl")
  expose = true
  merge_strategy = "deep"
}

# Depend on the provision unit to ensure VMs are created first
dependency "provision" {
  config_path = "../provision"
  
  # Mock outputs for plan/validation when provision hasn't been applied yet
  mock_outputs = {
    control_plane_ips = ["192.168.1.10", "192.168.1.11", "192.168.1.12"]
    worker_ips = ["192.168.1.20", "192.168.1.21"]
    cluster_name = "talos-cluster"
  }
  mock_outputs_allowed_terraform_commands = ["init", "validate", "plan"]
}

# Inputs for the bootstrap module
inputs = {
  # Pass outputs from provision phase
  control_plane_ips = dependency.provision.outputs.control_plane_ips
  worker_ips = dependency.provision.outputs.worker_ips
  cluster_name = dependency.provision.outputs.cluster_name
  
  # Add additional bootstrap configuration here
  # Example:
  # cluster_endpoint = "https://talos.k8s.local:6443"
  # kubernetes_version = "v1.29.0"
  # See the external module documentation for all available inputs
}
