previous config

```
resource "proxmox_virtual_environment_download_file" "image" {
  content_type = "iso"
  datastore_id = "local"
  file_name    = "ubuntu.img"
  node_name    = var.virtual_environment.node_name
  url          = var.image_url
  overwrite    = false
}

module "proxmox-ubuntu-vm" {
  for_each    = local.hosts
  source      = "./modules/proxmox-ubuntu-vm"
  vm_name     = each.key
  public_key  = local.public_key_content
  vm_username = var.vm_username
  cpu_cores   = 4
  memory_size = 8142
  static_ip_address = "${each.value.ansible_host}/24"
  ip_type     = "static"
  image_id    = proxmox_virtual_environment_download_file.image.id
  gateway     = local.gateway
  pve_datastore_id = var.virtual_environment.datastore_id
  dns_servers = local.dns_servers
}

```