
output "vm_ipv4_address" {
  value = module.proxmox-ubuntu-vm[*].ipv4_address
}

output "ansible_inventory" {
  value = <<-EOT
    [microk8s]
    %{ for idx, ip in module.proxmox-ubuntu-vm.ipv4_address ~}
    microk8s-node-${idx + 1} ansible_host=${ip} ansible_user=${var.vm_username} ansible_ssh_private_key_file=${var.priv_key_path}
    %{ endfor ~}
  EOT
  sensitive = true  # Optional: Hide inventory from Terraform CLI output
}
