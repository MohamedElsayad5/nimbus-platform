output "workload_identity_pool_name" {
  description = "Full resource name of the Workload Identity Pool. Used in GitHub Actions workflow."
  value       = google_iam_workload_identity_pool.github.name
}

output "workload_identity_provider_name" {
  description = "Full resource name of the WIF provider. This is what you paste into the GitHub Actions workflow as 'workload_identity_provider'."
  value       = google_iam_workload_identity_pool_provider.github.name
}
