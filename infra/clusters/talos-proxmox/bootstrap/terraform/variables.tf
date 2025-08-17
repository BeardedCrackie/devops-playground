variable "cluster_name" {
  description = "Name of the Talos cluster"
  type        = string
  default     = "homelab-k8s"
}

variable "cluster_endpoint" {
  description = "Cluster endpoint URL"
  type        = string
  default     = "https://192.168.0.60:6443"
}

variable "kubernetes_version" {
  description = "Kubernetes version to use"
  type        = string
  default     = "1.30.6"
}

variable "talos_version" {
  description = "Talos version to use"
  type        = string
  default     = "v1.10.6"
}
