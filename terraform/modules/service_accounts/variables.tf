variable "project_id" { type = string }

variable "gke_sa_name" {
  description = "Name for the GKE node service account."
  type        = string
  default     = "nimbus-gke-nodes"
}

variable "app_sa_name" {
  description = "Name for the application workload service account (used by pods via Workload Identity)."
  type        = string
  default     = "nimbus-app"
}

variable "cicd_sa_name" {
  description = "Name for the CI/CD pipeline service account (GitHub Actions via OIDC WIF)."
  type        = string
  default     = "nimbus-cicd"
}
