resource "kubernetes_namespace" "registry" {
  metadata {
    name = "registry"
  }
}

resource "kubernetes_manifest" "registry-deployment" {
  manifest = yamldecode(<<-EOT
    apiVersion: apps/v1
    kind: Deployment
    metadata:
      name: registry
      namespace: ${kubernetes_namespace.registry.metadata[0].name}
    spec:
      replicas: 1
      selector:
        matchLabels:
          app: registry
      template:
        metadata:
          labels:
            app: registry
        spec:
          containers:
          - name: registry
            image: registry:2
            ports:
            - containerPort: 5000
            volumeMounts:
            - name: registry-storage
              mountPath: /var/lib/registry
          volumes:
          - name: registry-storage
            emptyDir: {}
  EOT
  )
}

resource "kubernetes_manifest" "registry-service" {
  depends_on = [kubernetes_manifest.registry-deployment]
  manifest = yamldecode(<<-EOT
    apiVersion: v1
    kind: Service
    metadata:
      name: registry
      namespace: ${kubernetes_namespace.registry.metadata[0].name}
    spec:
      selector:
        app: registry
      ports:
      - protocol: TCP
        port: 5000
        targetPort: 5000
      type: ClusterIP
  EOT
  )
}