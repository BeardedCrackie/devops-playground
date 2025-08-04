module "proxmox-ubuntu-vm" {
  source = "./modules/proxmox-ubuntu-vm"
  vm_count  = 3  # This will create 3 VM instances
  vm_name = var.project_name
  cpu_cores = 4
  memory_size = 8142
  public_key = local.public_key_content
  vm_username = var.vm_username
}
