
locals {
  controlplane_ip = data.terraform_remote_state.proxmox_talos.outputs.controlplane_ip
  worker_ips      = data.terraform_remote_state.proxmox_talos.outputs.worker_ips
  all_nodes       = concat([local.controlplane_ip], local.worker_ips)
}
