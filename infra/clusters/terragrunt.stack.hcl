unit "provision" {
  source = "git::git@github.com:BeardedCrackie/infra-playground.git//infra/talos-proxmox/provision?ref=main"
  path   = "provision"
}

unit "bootstrap" {
  source = "git::git@github.com:BeardedCrackie/infra-playground.git//infra/talos-proxmox/bootstrap?ref=main"
  path   = "bootstrap"
}
