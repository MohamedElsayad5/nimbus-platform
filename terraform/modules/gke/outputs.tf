output "cluster_name" {
  value = google_container_cluster.primary.name
}

output "cluster_endpoint" {
  description = "The IP address of the GKE control plane. Used to configure kubectl."
  value       = google_container_cluster.primary.endpoint
  sensitive   = true
}

output "cluster_ca_certificate" {
  description = "Base64-encoded public CA certificate of the cluster. Used to verify the control plane TLS cert."
  value       = google_container_cluster.primary.master_auth[0].cluster_ca_certificate
  sensitive   = true
}

output "cluster_location" {
  value = google_container_cluster.primary.location
}

output "workload_identity_pool" {
  description = "The Workload Identity pool for this cluster. Annotate Kubernetes SAs with this."
  value       = "${var.project_id}.svc.id.goog"
}

output "get_credentials_command" {
  description = "Run this command to configure kubectl after terraform apply."
  value       = "gcloud container clusters get-credentials ${var.cluster_name} --zone ${var.zone} --project ${var.project_id}"
}
