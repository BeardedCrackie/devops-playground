# Terragrunt configuration for Talos VM provisioning phase
# This unit provisions Talos VMs on Proxmox infrastructure

terraform {
  source = "git::git@github.com:BeardedCrackie/infra-playground.git//infra/talos-proxmox/provision?ref=v0.1.1"
}

# Include root terragrunt configuration if it exists
include "root" {
  path = find_in_parent_folders("terragrunt.hcl")
  expose = true
  merge_strategy = "deep"
}

# Inputs for the provisioning module
inputs = {
  # Add your Proxmox and VM configuration here
  # Example:
  # proxmox_host = "proxmox.local"
  # vm_count = 3
  # vm_template = "talos-template"
  # See the external module documentation for all available inputs
}
