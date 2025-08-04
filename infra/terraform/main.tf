module "proxmox-ubuntu-vm" {
  source = "./modules/proxmox-ubuntu-vm"
  vm_count  = 3  # This will create 3 VM instances
  vm_name = var.project_name
  cpu_cores = 4
  memory_size = 8142
  public_key = local.public_key_content
  vm_username = var.vm_username
}

module "ansible_microk8s" {
  source = "./modules/ansible-microk8s"
  vm_username = var.vm_username
  priv_key_path = var.priv_key_path
  vm_ips = module.proxmox-ubuntu-vm.ipv4_address
  depends_on = [module.proxmox-ubuntu-vm]
}

module "apps_init" {
  source = "./modules/apps-init"
  depends_on = [module.ansible_microk8s]
}
