module "proxmox-ubuntu-vm" {
  source = "./modules/proxmox-ubuntu-vm"
  vm_count  = 3  # This will create 3 VM instances
  vm_name = var.project_name
  cpu_cores = 4
  memory_size = 8142
  public_key = local.public_key_content
  vm_username = var.vm_username
}

module "ansible_microk8s" {
  source = "./modules/ansible-microk8s"
  vm_username = var.vm_username
  priv_key_path = var.priv_key_path
  vm_ips = module.proxmox-ubuntu-vm.ipv4_address
  depends_on = [module.proxmox-ubuntu-vm]
}

resource "kubernetes_namespace" "argocd" {
  depends_on = [module.ansible_microk8s]  # Ensure Ansible creates the cluster first
  metadata {
    name = "argocd"
  }
}

resource "helm_release" "argocd" {
  name       = "argocd"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  namespace  = kubernetes_namespace.argocd.metadata[0].name

  values = [
    <<-EOF
    server:
      service:
        type: NodePort  # Change to "LoadBalancer" "NodePort" or "ClusterIP" if needed
    EOF
  ]
}

resource "kubernetes_namespace" "monitoring" {
  depends_on = [module.ansible_microk8s]
  metadata {
    name = "monitoring"
  }
}

resource "helm_release" "prometheus" {
  name       = "prometheus"
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "kube-prometheus-stack"
  namespace  = kubernetes_namespace.monitoring.metadata[0].name

  values = [
    <<-EOF
    prometheus:
      service:
        type: NodePort
        #nodePort: 30090

    grafana:
      service:
        type: NodePort
        #nodePort: 3081
    EOF
  ]
}
