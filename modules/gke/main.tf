resource "google_compute_network" "vpc" {
  name                    = "csre-vpc"
  auto_create_subnetworks = false
}

resource "google_service_account" "gke_service_account" {
  account_id   = "gke-service-account"
  display_name = "GKE Service Account"
}

resource "google_container_cluster" "gke_cluster" {
  name     = "csre-gke-cluster"
  location = var.region

  network    = google_compute_network.vpc.name
  subnetwork = google_compute_subnetwork.subnet.name

  node_pool {
    name       = "default-pool"
    node_count = var.max_node_count

    node_config {
      service_account = google_service_account.gke_service_account.email
    }
  }
}
