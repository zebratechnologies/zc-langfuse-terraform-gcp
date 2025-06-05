# Create Cloud DNS zone
resource "google_dns_managed_zone" "this" {
  name        = replace(var.domain, ".", "-")
  dns_name    = "${var.domain}."
  description = "DNS zone for Langfuse domain"
}

resource "google_dns_managed_zone" "externaldns_managed_zone_with_sub" {
  count = var.apex_domain != "" && var.subdomain != "" ? 1 : 0

  name        = "${replace(var.subdomain, ".", "-")}-${replace(var.apex_domain, ".", "-")}-sub"
  dns_name    = "${var.subdomain}.${var.apex_domain}."
  description = "Langfuse DNS subdomain zone managed by terraform"

  force_destroy = true
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
# resource "google_dns_record_set" "this" {
#   name         = google_dns_managed_zone.this.dns_name
#   managed_zone = google_dns_managed_zone.this.name
#   type         = "A"
#   ttl          = 300

#   rrdatas = [data.kubernetes_ingress_v1.langfuse.status.0.load_balancer.0.ingress.0.ip]
# }

resource "google_dns_record_set" "externaldns_record_set_with_sub" {
  count = var.apex_domain != "" && var.subdomain != "" && var.apex_domain_integration_enabled ? 1 : 0

  name         = google_dns_managed_zone.externaldns_managed_zone_with_sub[count.index].dns_name
  managed_zone = replace(var.apex_domain, ".", "-")
  type         = "NS"
  ttl          = 60
  project      = var.apex_domain_gcp_project
  rrdatas      = flatten(google_dns_managed_zone.externaldns_managed_zone_with_sub[count.index].name_servers)
  depends_on   = [google_dns_managed_zone.externaldns_managed_zone_with_sub]
}
