# Root Terragrunt configuration for Talos cluster management
# This file contains common settings shared across all units

# Configure Terragrunt to automatically store state in a remote backend
# Uncomment and configure for production use
# remote_state {
#   backend = "s3"
#   config = {
#     bucket         = "my-terraform-state"
#     key            = "${path_relative_to_include()}/terraform.tfstate"
#     region         = "us-east-1"
#     encrypt        = true
#     dynamodb_table = "terraform-locks"
#   }
#   generate = {
#     path      = "backend.tf"
#     if_exists = "overwrite_terragrunt"
#   }
# }

# Configure Terraform settings
terraform {
  # Force Terraform to keep the provider versions consistent
  extra_arguments "common_vars" {
    commands = get_terraform_commands_that_need_vars()
  }
  
  # Automatically retry on errors
  extra_arguments "retry_lock" {
    commands  = get_terraform_commands_that_need_locking()
    arguments = ["-lock-timeout=10m"]
  }
}

# Generate provider configuration
generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
terraform {
  required_version = ">= 1.0"
  
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "~> 0.50"
    }
    talos = {
      source  = "siderolabs/talos"
      version = "~> 0.7"
    }
  }
}
EOF
}

# Common inputs that can be used across all units
inputs = {
  # Add common variables here that should be available to all units
  # These can be overridden in individual unit terragrunt.hcl files
  
  # Example:
  # tags = {
  #   managed_by = "terragrunt"
  #   project    = "devops-playground"
  # }
}
