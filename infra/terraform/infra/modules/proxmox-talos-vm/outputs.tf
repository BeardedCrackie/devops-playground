output "vm_name" {
  description = "Name of the created VM"
  value       = proxmox_virtual_environment_vm.talos_vm.name
}

output "vm_id" {
  description = "ID of the created VM"
  value       = proxmox_virtual_environment_vm.talos_vm.id
}

output "ipv4_address" {
  description = "IPv4 address of the VM"
  value       = length(proxmox_virtual_environment_vm.talos_vm.ipv4_addresses) > 1 ? proxmox_virtual_environment_vm.talos_vm.ipv4_addresses[1][0] : null
}

output "mac_address" {
  description = "MAC address of the VM"
  value       = proxmox_virtual_environment_vm.talos_vm.mac_addresses[0]
}

output "node_name" {
  description = "Proxmox node where the VM is created"
  value       = proxmox_virtual_environment_vm.talos_vm.node_name
}
