output "cluster_name" {
  description = "GKE cluster name."
  value       = module.gke.cluster_name
}

output "get_credentials_command" {
  description = "Run this after terraform apply to configure kubectl."
  value       = module.gke.get_credentials_command
}

output "artifact_registry_url" {
  description = "Docker registry URL. Use this as the image prefix in your CI/CD pipeline."
  value       = module.artifact_registry.repository_url
}

output "wif_provider" {
  description = "Workload Identity Federation provider. Paste this into your GitHub Actions workflow."
  value       = module.iam.workload_identity_provider_name
}

output "cicd_sa_email" {
  description = "CI/CD service account email. Paste this into your GitHub Actions workflow."
  value       = module.service_accounts.cicd_sa_email
}

output "network_name" {
  value = module.network.network_name
}

output "monitoring_bucket" {
  value = module.monitoring.bucket_name
}
