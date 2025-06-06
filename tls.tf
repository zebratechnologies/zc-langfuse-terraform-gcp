# TLS Certificate
resource "google_compute_managed_ssl_certificate" "this" {
  name = var.name

  managed {
    domains = [var.domain]
  }
}

# Frontend config for HTTPs redirect
resource "kubectl_manifest" "https_redirect_new" {
  yaml_body = <<YAML
    apiVersion: networking.gke.io/v1beta1
    kind: FrontendConfig
    metadata:
      name:  https-redirect
      namespace: ${kubernetes_namespace.langfuse.metadata[0].name}
    spec:
      sslPolicy: zebra-ssl-policy-tls-1-1-custom
      redirectToHttps:
        enabled:  true
        responseCodeName: PERMANENT_REDIRECT
  YAML
}
