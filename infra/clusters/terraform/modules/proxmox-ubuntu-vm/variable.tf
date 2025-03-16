
variable "image_url" {
    type = string
    default = "https://cloud-images.ubuntu.com/noble/current/noble-server-cloudimg-amd64.img"
}

variable "vm_name" {
    type = string
    default = "vm"
}

variable "vm_count" {
    type = number
    default = 1
}

variable "public_key" {
    type = string
    description = "public key"
}

variable "vm_username" {
    type = string
    default = "ubuntu"
}

variable "cpu_cores" {
    type = number
    default = 1
}

variable "memory_size" {
    type = number
    default = 2048
}

variable "network_name" {
    type = string
    default = "vmbr0"
}

variable "pve_datastore_id" {
    type = string
    default = "local-zfs"
}

variable "pve_node_name" {
    type = string
    default = "proxmox"
}
