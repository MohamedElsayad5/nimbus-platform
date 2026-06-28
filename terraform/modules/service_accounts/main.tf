# ------------------------------------------------------------------------------
# SERVICE ACCOUNTS
# Three service accounts with strictly scoped permissions.
#
# 1. GKE Node SA (nimbus-gke-nodes)
#    Used by the Kubernetes nodes themselves (the VMs). Needs minimal permissions:
#    - Pull images from Artifact Registry
#    - Write logs to Cloud Logging
#    - Write metrics to Cloud Monitoring
#    - Read from Cloud Storage (for node bootstrap)
#    NEVER give nodes broad project editor/owner roles.
#
# 2. App SA (nimbus-app)
#    Used by application pods via Kubernetes Workload Identity.
#    No key files — pods exchange their Kubernetes service account token for
#    a GCP access token automatically via the GKE metadata server.
#    Only gets permissions it absolutely needs (e.g., read a specific GCS bucket).
#
# 3. CI/CD SA (nimbus-cicd)
#    Used by GitHub Actions via Workload Identity Federation (OIDC).
#    Needs to push Docker images and trigger GKE deployments.
#    Permissions scoped to exactly what the pipeline needs.
# ------------------------------------------------------------------------------

# --- GKE Node Service Account ---
resource "google_service_account" "gke_nodes" {
  project      = var.project_id
  account_id   = var.gke_sa_name
  display_name = "Nimbus GKE Node Service Account"
  description  = "Service account for GKE worker nodes. Minimal permissions — no editor role."
}

# --- Application Service Account ---
resource "google_service_account" "app" {
  project      = var.project_id
  account_id   = var.app_sa_name
  display_name = "Nimbus Application Service Account"
  description  = "Used by application pods via Workload Identity. No key files ever created."
}

# --- CI/CD Service Account ---
resource "google_service_account" "cicd" {
  project      = var.project_id
  account_id   = var.cicd_sa_name
  display_name = "Nimbus CI/CD Service Account"
  description  = "Used by GitHub Actions via Workload Identity Federation OIDC. No key files."
}

# --- GKE Node SA Permissions ---
# These are the minimum roles required for a GKE node to function.
# roles/logging.logWriter        → Write logs to Cloud Logging
# roles/monitoring.metricWriter  → Write metrics to Cloud Monitoring
# roles/monitoring.viewer        → Read monitoring data (required by some GKE components)
# roles/artifactregistry.reader  → Pull container images from Artifact Registry

locals {
  gke_node_roles = [
    "roles/logging.logWriter",
    "roles/monitoring.metricWriter",
    "roles/monitoring.viewer",
    "roles/artifactregistry.reader",
  ]
}

resource "google_project_iam_member" "gke_node_roles" {
  for_each = toset(local.gke_node_roles)

  project = var.project_id
  role    = each.value
  member  = "serviceAccount:${google_service_account.gke_nodes.email}"
}

# --- CI/CD SA Permissions ---
# roles/artifactregistry.writer  → Push images to Artifact Registry
# roles/container.developer      → Read GKE cluster credentials, deploy workloads
# roles/storage.objectAdmin      → Read/write Terraform state bucket
# roles/iam.serviceAccountTokenCreator → Allow WIF to impersonate this SA

locals {
  cicd_roles = [
    "roles/artifactregistry.writer",
    "roles/container.developer",
    "roles/storage.objectAdmin",
    "roles/iam.serviceAccountTokenCreator",
  ]
}

resource "google_project_iam_member" "cicd_roles" {
  for_each = toset(local.cicd_roles)

  project = var.project_id
  role    = each.value
  member  = "serviceAccount:${google_service_account.cicd.email}"
}
