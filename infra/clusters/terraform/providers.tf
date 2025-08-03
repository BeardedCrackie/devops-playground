terraform {
  required_providers {
    proxmox = {
      source = "bpg/proxmox"
      version = "0.70.1"
    }
    kubernetes = {
      source = "hashicorp/kubernetes"
      version = "2.36.0"
    } 
    helm = {
      source = "hashicorp/helm"
      version = "3.0.2"
    }
  }
}

provider "proxmox" {
  endpoint = var.virtual_environment.endpoint
  username = var.virtual_environment.username
  password = var.virtual_environment.password
  insecure  = true
  ssh {
    agent    = false
    private_key = local.priv_key_content
  }
}

provider "kubernetes" {
  config_path = module.ansible_microk8s.kubeconfig_path
}

provider "helm" {
  kubernetes = {
    config_path = module.ansible_microk8s.kubeconfig_path
  }
}
