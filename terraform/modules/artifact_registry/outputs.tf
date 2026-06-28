output "repository_id" {
  value = google_artifact_registry_repository.nimbus.repository_id
}

output "repository_url" {
  description = "The base URL for pushing/pulling images. Format: REGION-docker.pkg.dev/PROJECT/REPO"
  value       = "${var.region}-docker.pkg.dev/${var.project_id}/${var.repository_id}"
}
