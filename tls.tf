# TLS Certificate
resource "google_compute_managed_ssl_certificate" "this" {
  name = var.name

  managed {
    domains = [var.domain]
  }
}

resource "google_compute_ssl_policy" "custom-ssl-policy" {
  name            = "zebra-ssl-policy-tls-1-2-custom-for-langfuse"
  min_tls_version = "TLS_1_2"
  profile         = "CUSTOM"
  custom_features = ["TLS_ECDHE_ECDSA_WITH_AES_128_GCM_SHA256", "TLS_ECDHE_ECDSA_WITH_AES_256_GCM_SHA384", "TLS_ECDHE_ECDSA_WITH_CHACHA20_POLY1305_SHA256", "TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256", "TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384", "TLS_ECDHE_RSA_WITH_CHACHA20_POLY1305_SHA256", "TLS_RSA_WITH_AES_128_GCM_SHA256", "TLS_RSA_WITH_AES_256_GCM_SHA384"]
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
      sslPolicy: zebra-ssl-policy-tls-1-2-custom-for-langfuse
      redirectToHttps:
        enabled:  true
        responseCodeName: PERMANENT_REDIRECT
  YAML
}
