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

#resource "local_file" "ansible_inventory" {
#  filename = "ansible_inventory.ini"
#  content  = <<-EOF
#    [${var.project_name}]
#    ${join("\n", [for i in range(module.proxmox-ubuntu-vm.vm_count) : "${var.project_name}-${i+1} ansible_host=${module.proxmox-ubuntu-vm.ipv4_address[i]} ansible_user=${var.vm_username} ansible_ssh_private_key_file=${var.priv_key_path} ansible_python_interpreter=/usr/bin/python3"])}
#    [all:vars]
#    ansible_ssh_common_args='-o StrictHostKeyChecking=no'
#  EOF
#}
