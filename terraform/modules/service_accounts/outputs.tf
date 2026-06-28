output "gke_node_sa_email" {
  description = "Email of the GKE node service account. Used in GKE module node pool config."
  value       = google_service_account.gke_nodes.email
}

output "app_sa_email" {
  description = "Email of the app service account. Annotated onto the Kubernetes ServiceAccount for Workload Identity."
  value       = google_service_account.app.email
}

output "app_sa_id" {
  description = "Unique ID of the app service account."
  value       = google_service_account.app.unique_id
}

output "cicd_sa_email" {
  description = "Email of the CI/CD service account. Used in Workload Identity Federation pool configuration."
  value       = google_service_account.cicd.email
}
