resource "google_container_cluster" "this" {
  name     = var.name
  location = data.google_client_config.current.region

  # Enable Workload Identity
  workload_identity_config {
    workload_pool = "${data.google_client_config.current.project}.svc.id.goog"
  }

  enable_autopilot = true

  networking_mode = "VPC_NATIVE"
  network         = google_compute_network.this.name
  subnetwork      = google_compute_subnetwork.this.name

  deletion_protection = var.deletion_protection
}
