locals {
  master_authorized_networks_config = length(var.master_authorized_networks) == 0 ? [] : [{
    cidr_blocks : var.master_authorized_networks
  }]
  enable_private_cluster_config = (var.enable_private_nodes || var.enable_private_endpoint) ? true : false
  enable_vpc_native             = (var.ip_range_pods != "" || var.ip_range_services != "") ? true : false
}

resource "google_container_cluster" "this" {
  name     = var.name
  location = data.google_client_config.current.region
  remove_default_node_pool = true

  # Enable Workload Identity
  workload_identity_config {
    workload_pool = "${data.google_client_config.current.project}.svc.id.goog"
  }

  cluster_autoscaling {
    enabled = true
    resource_limits {
      resource_type = "cpu"
      minimum = 0
      maximum = 64
    }
    resource_limits {
      resource_type = "memory"
      minimum = 0
      maximum = 64
    }
  }

  dynamic "private_cluster_config" {
    for_each = local.enable_private_cluster_config ? [{
      enable_private_nodes    = var.enable_private_nodes
      enable_private_endpoint = var.enable_private_endpoint
      master_ipv4_cidr_block  = var.master_ipv4_cidr_block
    }] : []

    content {
      enable_private_endpoint = private_cluster_config.value.enable_private_endpoint
      enable_private_nodes    = private_cluster_config.value.enable_private_nodes
      master_ipv4_cidr_block  = private_cluster_config.value.master_ipv4_cidr_block
    }
  }

  dynamic "ip_allocation_policy" {
    for_each = local.enable_vpc_native ? [{
      ip_range_pods     = var.ip_range_pods
      ip_range_services = var.ip_range_services
    }] : []

    content {
      cluster_ipv4_cidr_block  = ip_allocation_policy.value.ip_range_pods
      services_ipv4_cidr_block = ip_allocation_policy.value.ip_range_services
    }
  }

  networking_mode = "VPC_NATIVE"
  network         = google_compute_network.this.name
  subnetwork      = google_compute_subnetwork.this.name

  initial_node_count = var.initial_cluster_node_count

  deletion_protection = var.deletion_protection
}

resource "kubectl_manifest" "enable_iap" {
  yaml_body = <<YAML
    apiVersion: cloud.google.com/v1
    kind: BackendConfig
    metadata:
      name:  iap-config
      namespace: ${kubernetes_namespace.langfuse.metadata[0].name}
    spec:
      timeoutSec: 60
      customResponseHeaders:
        headers:
          - "Strict-Transport-Security: max-age=63072000; includeSubDomains"
      iap:
        enabled:  true
        oauthclientCredentials:
          secretName: zc-iap-oauth-client
  YAML
}
