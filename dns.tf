# Create Cloud DNS zone
resource "google_dns_managed_zone" "this" {
  name        = replace(var.domain, ".", "-")
  dns_name    = "${var.domain}."
  description = "DNS zone for Langfuse domain"
}

# Get the load balancer IP
data "kubernetes_ingress_v1" "langfuse" {
  metadata {
    name      = "langfuse"
    namespace = kubernetes_namespace.langfuse.metadata[0].name
  }

  depends_on = [
    helm_release.langfuse
  ]
}

# Create DNS A record for the load balancer
resource "google_dns_record_set" "this" {
  name         = google_dns_managed_zone.this.dns_name
  managed_zone = google_dns_managed_zone.this.name
  type         = "A"
  ttl          = 300

  rrdatas = [data.kubernetes_ingress_v1.langfuse.status.0.load_balancer.0.ingress.0.ip]
}
