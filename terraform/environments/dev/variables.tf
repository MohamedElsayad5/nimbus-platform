variable "project_id" {
  description = "GCP Project ID. Set via TF_VAR_project_id environment variable or terraform.tfvars."
  type        = string
}

variable "project_number" {
  description = "GCP Project Number (numeric). Found in GCP Console → Project Info widget."
  type        = string
}

variable "region" {
  description = "Primary GCP region for all resources."
  type        = string
  default     = "us-central1"
}

variable "zone" {
  description = "GCP zone for the zonal GKE cluster. Must be within var.region."
  type        = string
  default     = "us-central1-a"
}

variable "github_org" {
  description = "GitHub organization or username. Used to scope Workload Identity Federation trust."
  type        = string
}

variable "github_repo" {
  description = "GitHub repository name (without org prefix). E.g., 'nimbus-platform'."
  type        = string
  default     = "nimbus-platform"
}

variable "authorized_networks" {
  description = "CIDRs allowed to reach the GKE API server. Add your current public IP here."
  type = list(object({
    cidr_block   = string
    display_name = string
  }))
  default = []
}
