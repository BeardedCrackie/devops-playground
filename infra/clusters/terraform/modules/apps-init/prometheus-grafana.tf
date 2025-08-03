
resource "kubernetes_namespace" "monitoring" {
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
