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
  config_path = "../k8s/kubeconfig"  # Path to the kubeconfig file from the VM
}

module "proxmox-ubuntu-vm" {
  source = "./modules/proxmox-ubuntu-vm"
  vm_count  = 3  # This will create 3 VM instances
  vm_name = var.project_name
  public_key = local.public_key_content
  vm_username = var.vm_username
}

resource "null_resource" "ansible_inventory" {
depends_on = [module.proxmox-ubuntu-vm]
  provisioner "local-exec" {
    command = <<-EOT
      # Generate inventory file
      echo "[microk8s]" > ../ansible/inventory.ini
      i=1
      for ip in ${join(" ", module.proxmox-ubuntu-vm.ipv4_address)}; do
        echo "microk8s-node-$i ansible_host=$ip ansible_user=${var.vm_username} ansible_ssh_private_key_file=${var.priv_key_path}" >> ../ansible/inventory.ini
        i=$((i+1))
      done
    EOT
  }
}

resource "null_resource" "ansible_setup_microk8s" {
depends_on = [null_resource.ansible_inventory]
  provisioner "local-exec" {
    command = <<-EOT
      ansible-playbook -i ../ansible/inventory.ini ../ansible/after-provision-setup.yaml \
        -e "ansible_ssh_extra_args='-o StrictHostKeyChecking=no'"
      ansible-playbook -i ../ansible/inventory.ini ../ansible/microk8s-setup.yaml \
        -e "ansible_user=${var.vm_username}" 
    EOT
  }
}
