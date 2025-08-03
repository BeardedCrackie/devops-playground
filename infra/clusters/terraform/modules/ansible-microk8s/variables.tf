variable "vm_username" {
  description = "The username for the VMs."
  type        = string
}

variable "priv_key_path" {
  description = "The path to the private SSH key."
  type        = string
}

variable "vm_ips" {
  description = "List of VM IP addresses."
  type        = list(string)
}