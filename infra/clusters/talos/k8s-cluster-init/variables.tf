variable "metallb_ip_pool" {
  description = "IP pool for MetalLB"
  type        = string
}

variable "kubeconfig_path" {
  description = "Path to the kubeconfig file."
  type        = string
}
