
resource "proxmox_virtual_environment_vm" "ubuntu_vm" {
  count      = var.vm_count
  name       = "${var.vm_name}-${count.index + 1}"
  description = "Managed by Terraform"
  tags        = ["terraform", "ubuntu", "ansible", "microk8s"]
  started = true

  #timeout in seconds
  timeout_create = "18000"

  node_name = var.pve_node_name

  cpu {
    cores = var.cpu_cores
  }

  memory {
    dedicated = var.memory_size
  }

  agent {
    enabled = true
  }

  startup {
    order      = "3"
    up_delay   = "60"
    down_delay = "60"
  }

  disk {
    datastore_id = var.pve_datastore_id
    file_id      = proxmox_virtual_environment_download_file.image.id
    interface    = "virtio0"
    file_format = "raw"
    iothread     = true
    discard      = "on"
    size         = 20
  }

  initialization {
    datastore_id = var.pve_datastore_id
    ip_config {
      ipv4 {
        address = "dhcp"
      }
    }
    
    user_data_file_id = proxmox_virtual_environment_file.cloud_config.id
  }

  network_device {
    bridge = var.network_name
  }

  operating_system {
    type = "l26"
  }

  tpm_state {
    version = "v2.0"
    datastore_id = var.pve_datastore_id
  }
}

resource "proxmox_virtual_environment_download_file" "image" {
  content_type = "iso"
  datastore_id = "local"
  file_name    = "${var.vm_name}.img"
  node_name    = var.pve_node_name
  url          = var.image_url
  overwrite = false
}

resource "proxmox_virtual_environment_file" "cloud_config" {
  content_type = "snippets"
  datastore_id = "local"
  node_name    = var.pve_node_name

  source_raw {
    #hostname: ${var.vm_name}-${vm_count.index + 1}
    data = <<-EOF
    #cloud-config
    users:
      - default
      - name: ${var.vm_username}
        groups:
          - sudo
        shell: /bin/bash
        ssh_authorized_keys:
          - ${var.public_key}
        sudo: ALL=(ALL) NOPASSWD:ALL
    runcmd:
        - apt update >> /tmp/cloud-config
        - apt upgrade -y >> /tmp/cloud-config
        - apt install -y qemu-guest-agent net-tools >> /tmp/cloud-config
        - timedatectl set-timezone Europe/Bratislava >> /tmp/cloud-config
        - systemctl enable qemu-guest-agent >> /tmp/cloud-config
        - systemctl start qemu-guest-agent >> /tmp/cloud-config
        - echo "done" > /tmp/cloud-config.done
    EOF
    file_name = "cloud-config.yaml"
  }
}
