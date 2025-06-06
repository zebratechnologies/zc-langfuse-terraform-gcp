terraform {
  backend "gcs" {
    prefix = "states"
  }
}

provider "google" {
  # Change this according to project name, and region required.
  project = "zac-02-d"
  region = "us-east1"
}

module "langfuse" {
  source = "../.."

  apex_domain_gcp_project = "cto-eva-cust-domain-poc-10"

  domain =  "lf-prod.cto-si.zebra.com"
  apex_domain = "cto-si.zebra.com"
  subdomain = "lf-prod"
  apex_domain_integration_enabled = true

  # Optional use a different name for your installation
  # e.g. when using the module multiple times on the same GCP account
  name = "langfuse"

  # Optional: Configure the Subnetwork
  subnetwork_cidr = "10.110.0.0/16"

  # Optional: Configure the Kubernetes cluster
  kubernetes_namespace = "langfuse"

  # Optional: Configure the database instances
  database_instance_tier              = "db-perf-optimized-N-2"
  database_instance_availability_type = "REGIONAL"
  database_instance_edition = "ENTERPRISE_PLUS"

  # Optional: Configure the cache
  cache_tier           = "STANDARD_HA"
  cache_memory_size_gb = 1

  # Optional: Configure the Langfuse Helm chart version
  langfuse_chart_version = "1.2.15"

  ip_range_pods                        = "10.120.0.0/16"
  ip_range_services                    = "10.130.0.0/16"
  master_ipv4_cidr_block = "10.0.0.0/28"

  initial_cluster_node_count = 3
  initial_primary_node_pool_node_count =  1
  enable_private_nodes = true

  deletion_protection = false
}

provider "kubernetes" {
  host                   = module.langfuse.cluster_host
  cluster_ca_certificate = module.langfuse.cluster_ca_certificate
  token                  = module.langfuse.cluster_token
}

provider "helm" {
  kubernetes {
    host                   = module.langfuse.cluster_host
    cluster_ca_certificate = module.langfuse.cluster_ca_certificate
    token                  = module.langfuse.cluster_token
  }
}
