# This file provisions cert-manager and configures it to use your Talos CA for issuing ingress certificates.
# It includes all steps: Helm install, CA secret, ClusterIssuer, and example Certificate.

resource "helm_release" "cert_manager" {
  name       = "cert-manager"
  namespace  = "cert-manager"
  repository = "https://charts.jetstack.io"
  chart      = "cert-manager"
  version    = "v1.14.4"
  create_namespace = true

  set = [
    {
      name  = "installCRDs"
      value = "true"
    }
  ]
}

#variable "ca_cert_path" {
#  description = "Path to the CA certificate file"
#  type        = string
#}
#
#variable "ca_key_path" {
#  description = "Path to the CA private key file"
#  type        = string
#}
#
#resource "kubernetes_secret" "talos_ca" {
#  metadata {
#    name      = "talos-ca"
#    namespace = "cert-manager"
#  }
#  type = "kubernetes.io/tls"
#  data = {
#    "tls.crt" = filebase64(var.ca_cert_path)
#    "tls.key" = filebase64(var.ca_key_path)
#  }
#  depends_on = [helm_release.cert_manager]
#}
