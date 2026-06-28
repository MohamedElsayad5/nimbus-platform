variable "project_id" { type = string }
variable "project_number" {
  description = "The numeric project number (not ID). Required for Workload Identity Federation pool naming."
  type        = string
}

variable "github_org" {
  description = "GitHub organization or username that owns the repository."
  type        = string
}

variable "github_repo" {
  description = "GitHub repository name (without the org prefix)."
  type        = string
}

variable "cicd_sa_email" {
  description = "Email of the CI/CD service account to be impersonated by GitHub Actions."
  type        = string
}

variable "app_sa_email" {
  description = "Email of the application service account for Workload Identity binding."
  type        = string
}

variable "k8s_namespace" {
  description = "Kubernetes namespace where the application runs. Used to scope Workload Identity binding."
  type        = string
  default     = "nimbus"
}

variable "k8s_service_account" {
  description = "Kubernetes ServiceAccount name that will impersonate the GCP app service account."
  type        = string
  default     = "nimbus-app"
}
