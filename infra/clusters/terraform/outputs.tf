
output "vm_ipv4_address" {
  value = module.proxmox-ubuntu-vm[*].ipv4_address
}
