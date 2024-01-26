# VPC Configuration
resource "google_compute_network" "vpc" {
  name                    = "csre-vpc"
  auto_create_subnetworks = false
}

# Service Account Configuration
resource "google_service_account" "gke_service_account" {
  account_id   = "gke-service-account"
  display_name = "GKE Service Account"
}

# GKE Cluster Module
module "gke_cluster" {
  source          = "../modules/gke"
  project_id      = var.project_id
  region          = var.region
  max_node_count  = var.max_node_count
  vpc_id          = google_compute_network.vpc.id
  service_account = google_service_account.gke_service_account.email
}
