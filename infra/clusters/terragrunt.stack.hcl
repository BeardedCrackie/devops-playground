unit "provision" {
  source = "git::git@github.com:BeardedCrackie/infra-playground.git//infra/talos-proxmox/provision?ref=v0.1.1"
  path   = "provision"
}

unit "bootstrap" {
  source = "git::git@github.com:BeardedCrackie/infra-playground.git//infra/talos-proxmox/bootstrap?ref=v0.1.1"
  path   = "bootstrap"
}
