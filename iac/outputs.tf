output "vpc_id" {
  value = google_compute_network.vpc.id
}

output "service_account_email" {
  value = google_service_account.gke_service_account.email
}

output "gke_cluster_id" {
  value = module.gke_cluster.cluster_id
}
