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

resource "proxmox_virtual_environment_vm" "ubuntu_vm" {
  count      = 3
  name       = "${var.project.name}-${var.vm_name}-${count.index + 1}"
  description = "Managed by Terraform"
  tags        = ["terraform", "ubuntu", "ansible", "microk8s"]
  started = true

  #timeout in seconds
  timeout_create = "18000"

  node_name = var.virtual_environment.node_name

  cpu {
    cores = 4
  }

  memory {
    dedicated = 8192
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
    datastore_id = var.virtual_environment.datastore_id
    file_id      = proxmox_virtual_environment_download_file.image.id
    interface    = "virtio0"
    file_format = "raw"
    iothread     = true
    discard      = "on"
    size         = 20
  }

  initialization {
    datastore_id = var.virtual_environment.datastore_id
    ip_config {
      ipv4 {
        #address = "${var.vm.ip}/${var.vm.prefix}"
        #gateway = "${var.vm.gw}"
        address = "dhcp"
      }
    }

    dns {
      servers = "${var.vm.dns_servers}"
    }
    
    user_data_file_id = proxmox_virtual_environment_file.cloud_config.id
  }

  network_device {
    bridge = "vmbr0"
  }

  operating_system {
    type = "l26"
  }

  tpm_state {
    version = "v2.0"
    datastore_id = var.virtual_environment.datastore_id
  }

}

resource "proxmox_virtual_environment_download_file" "image" {
  content_type = "iso"
  datastore_id = "local"
  file_name    = "${var.project.name}.img"
  node_name    = var.virtual_environment.node_name
  url          = var.image_url
  overwrite = false
}

resource "proxmox_virtual_environment_file" "cloud_config" {
  content_type = "snippets"
  datastore_id = "local"
  node_name    = var.virtual_environment.node_name

  source_raw {
    #hostname: ${var.project.name}-${var.vm_name}-${count.index + 1}
    data = <<-EOF
    #cloud-config
    users:
      - default
      - name: ${var.vm.username}
        groups:
          - sudo
        shell: /bin/bash
        ssh_authorized_keys:
          - ${local.public_key_content}
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

resource "local_file" "ansible_inventory" {
  filename = "ansible_inventory.ini"
  content  = <<-EOF
    [${var.project.name}]
    ${join("\n", [for i in range(3) : "${var.project.name}-${var.vm_name}-${i+1} ansible_host=${proxmox_virtual_environment_vm.ubuntu_vm[i].ipv4_addresses[1][0]} ansible_user=${var.vm.username} ansible_ssh_private_key_file=${var.priv_key_path} ansible_python_interpreter=/usr/bin/python3"])}
    [all:vars]
    ansible_ssh_common_args='-o StrictHostKeyChecking=no'
  EOF
}
