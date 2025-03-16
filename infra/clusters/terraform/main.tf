terraform {
  required_providers {
    proxmox = {
      source = "bpg/proxmox"
      version = "0.70.1"
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

module "proxmox-ubuntu-vm" {
  source = "./modules/proxmox-ubuntu-vm"
  vm_count  = 3  # This will create 3 VM instances
  vm_name = var.project_name
  public_key = local.public_key_content
  vm_username = var.vm_username
}

resource "null_resource" "run_ansible" {
depends_on = [module.proxmox-ubuntu-vm]
  triggers = {
    always_run = timestamp()  # Changes on every apply, forcing execution
  }
  provisioner "local-exec" {
    command = <<-EOT
      # Write inventory to a file
      terraform output -raw ansible_inventory > ../ansible/inventory.ini

      # Run Ansible Playbook
      # Run Ansible Playbook
      ansible-playbook -i ../ansible/inventory.ini ../ansible/microk8s-setup.yaml

    EOT
  }
}
