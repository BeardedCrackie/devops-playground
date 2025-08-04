data "local_file" "ansible_inventory" {
  filename = "../ansible/inventory.yaml"
}

locals {
  inventory = yamldecode(data.local_file.ansible_inventory.content)
  hosts = local.inventory["microk8s"]["hosts"]
}

module "proxmox-ubuntu-vm" {
  for_each    = local.hosts
  source      = "./modules/proxmox-ubuntu-vm"
  vm_name     = each.key
  public_key  = local.public_key_content
  vm_username = var.vm_username
  cpu_cores   = 4
  memory_size = 8142
  static_ip_address = each.value.ansible_host
  ip_type     = "static"
  gateway     = "192.168.0.1"
}