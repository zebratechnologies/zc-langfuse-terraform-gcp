variable "name" {
  description = "Name to use for or prefix resources with"
  type        = string
  default     = "langfuse"
}

variable "domain" {
  description = "Domain name used to host langfuse on (e.g., langfuse.company.com)"
  type        = string
}

variable "use_encryption_key" {
  description = "Whether or not to use an Encryption key for LLM API credential and integration credential store"
  type        = bool
  default     = true
}

variable "kubernetes_namespace" {
  description = "Namespace to deploy langfuse to"
  type        = string
  default     = "langfuse"
}

variable "subnetwork_cidr" {
  description = "CIDR block for Subnetwork"
  type        = string
  default     = "10.110.0.0/16"
}

variable "database_instance_tier" {
  description = "The machine type to use for the database instance"
  type        = string
  default     = "db-perf-optimized-N-2"
}

variable "database_instance_edition" {
  description = "The edition of the database instance"
  type        = string
  default     = "ENTERPRISE_PLUS"
}

variable "database_instance_availability_type" {
  description = "The availability type to use for the database instance"
  type        = string
  default     = "REGIONAL"
}

variable "cache_tier" {
  description = "The service tier of the instance"
  type        = string
  default     = "STANDARD_HA"
}

variable "cache_memory_size_gb" {
  description = "Redis memory size in GB"
  type        = number
  default     = 1
}

variable "deletion_protection" {
  description = "Whether or not to enable deletion_protection on data sensitive resources"
  type        = bool
  default     = true
}

variable "langfuse_chart_version" {
  description = "Version of the Langfuse Helm chart to deploy"
  type        = string
  default     = "1.2.15"
}

variable "apex_domain_gcp_project" {
  description = "The GCP project the parent domain is managed by, used to write recordsets for a subdomain if set.  Defaults to current project."
  type        = string
  default     = ""
}

variable "apex_domain" {
  description = "The apex / parent domain to be allocated to the cluster"
  type        = string
  default     = ""
}

variable "subdomain" {
  description = "Optional sub domain for the installation"
  type        = string
  default     = ""
}

variable "apex_domain_integration_enabled" {
  description = "Add recordsets from a subdomain to a parent / apex domain"
  type        = bool
  default     = true
}

variable "initial_cluster_node_count" {
  description = "initial number of cluster nodes"
  type        = number
  default     = 3
}

variable "initial_primary_node_pool_node_count" {
  description = "initial number of pool nodes"
  type        = number
  default     = 1
}

variable "ip_range_pods" {
  type        = string
  description = "The IP range in CIDR notation to use for pods. Set to /netmask (e.g. /18) to have a range chosen with a specific netmask. Enables VPC-native"
  default     = ""
}

variable "ip_range_services" {
  type        = string
  description = "The IP range in CIDR notation use for services. Set to /netmask (e.g. /21) to have a range chosen with a specific netmask. Enables VPC-native"
  default     = ""
}

variable "enable_private_endpoint" {
  type        = bool
  description = "(Beta) Whether the master's internal IP address is used as the cluster endpoint. Requires VPC-native"
  default     = false
}

variable "enable_private_nodes" {
  type        = bool
  description = "(Beta) Whether nodes have internal IP addresses only. Requires VPC-native"
  default     = false
}

variable "master_ipv4_cidr_block" {
  type        = string
  description = "The IP range in CIDR notation to use for the hosted master network.  This range must not overlap with any other ranges in use within the cluster's network, and it must be a /28 subnet"
  default     = "10.0.0.0/28"
}

variable "master_authorized_networks" {
  type        = list(object({ cidr_block = string, display_name = string }))
  description = "List of master authorized networks. If none are provided, disallow external access (except the cluster node IPs, which GKE automatically allowlists)."
  default = [
    {
      "cidr_block"   = "0.0.0.0/0",
      "display_name" = "any"
    },
  ]
}
