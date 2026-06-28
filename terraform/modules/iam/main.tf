# ------------------------------------------------------------------------------
# IAM MODULE — Workload Identity Federation
#
# This module implements two distinct identity federation mechanisms:
#
# 1. GitHub Actions → GCP (OIDC Workload Identity Federation)
#    Allows GitHub Actions to authenticate as a GCP service account
#    without any stored credentials. Flow:
#      GitHub Actions job starts
#      → GH generates a signed JWT with claims about the repo/branch/workflow
#      → Job calls GCP STS (Security Token Service) with the JWT
#      → GCP validates JWT against GitHub's OIDC discovery endpoint
#      → GCP issues a short-lived (1hr) access token for the CI/CD SA
#      → Job uses token to push images, deploy, etc.
#
# 2. Kubernetes Pods → GCP (GKE Workload Identity)
#    Allows pods to authenticate as GCP service accounts without key files.
#    Flow:
#      Pod has a Kubernetes ServiceAccount
#      → KSA is annotated with GCP SA email
#      → GCP SA has IAM binding allowing KSA to impersonate it
#      → GKE metadata server intercepts pod's requests to metadata endpoint
#      → Returns short-lived credentials for the GCP SA
#      → Pod can call GCP APIs (GCS, Pub/Sub, etc.) natively
# ------------------------------------------------------------------------------

# --- Workload Identity Pool ---
# A pool groups external identity providers. We create one pool for Nimbus.
# The pool ID becomes part of the principal identifier used in IAM bindings.
resource "google_iam_workload_identity_pool" "github" {
  project                   = var.project_id
  workload_identity_pool_id = "nimbus-github-pool"
  display_name              = "Nimbus GitHub Actions Pool"
  description               = "Workload Identity Pool for GitHub Actions OIDC authentication. No key files needed."
  disabled                  = false
}

# --- Workload Identity Pool Provider ---
# The provider configures trust between the pool and GitHub's OIDC endpoint.
# GitHub's OIDC issuer is https://token.actions.githubusercontent.com
# Each token issued by GitHub contains claims we can use to restrict access.
resource "google_iam_workload_identity_pool_provider" "github" {
  project                            = var.project_id
  workload_identity_pool_id          = google_iam_workload_identity_pool.github.workload_identity_pool_id
  workload_identity_pool_provider_id = "nimbus-github-provider"
  display_name                       = "GitHub Actions OIDC Provider"
  description                        = "Trusts JWTs issued by GitHub Actions for the nimbus-platform repository."

  # Attribute mapping: translates JWT claims into Google attributes.
  # google.subject     = the unique identifier for this external identity
  # attribute.actor    = who triggered the workflow (useful for audit logs)
  # attribute.repository = which repo triggered the workflow
  attribute_mapping = {
    "google.subject"             = "assertion.sub"
    "attribute.actor"            = "assertion.actor"
    "attribute.repository"       = "assertion.repository"
    "attribute.repository_owner" = "assertion.repository_owner"
  }

  # Attribute condition: ONLY allow tokens from our specific repository.
  # This is a critical security control. Without it, any GitHub repo could
  # potentially authenticate as our CI/CD service account.
  attribute_condition = "assertion.repository == '${var.github_org}/${var.github_repo}'"

  oidc {
    # GitHub's well-known OIDC discovery endpoint.
    issuer_uri = "https://token.actions.githubusercontent.com"
  }
}

# --- IAM Binding: Allow GitHub Actions to impersonate CI/CD SA ---
# This grants any workflow from our repository the ability to impersonate
# the CI/CD service account. In production, you'd tighten this further
# by also checking the branch (assertion.ref == 'refs/heads/main').
resource "google_service_account_iam_binding" "github_wif_binding" {
  service_account_id = "projects/${var.project_id}/serviceAccounts/${var.cicd_sa_email}"
  role               = "roles/iam.workloadIdentityUser"

  members = [
    "principalSet://iam.googleapis.com/${google_iam_workload_identity_pool.github.name}/attribute.repository/${var.github_org}/${var.github_repo}",
  ]
}

# --- GKE Workload Identity Binding ---
# Allows the Kubernetes ServiceAccount (KSA) in the app namespace to
# impersonate the GCP app service account. This binding must match exactly:
#   - project ID
#   - Kubernetes namespace
#   - Kubernetes ServiceAccount name
resource "google_service_account_iam_binding" "workload_identity_binding" {
  service_account_id = "projects/${var.project_id}/serviceAccounts/${var.app_sa_email}"
  role               = "roles/iam.workloadIdentityUser"

  members = [
    "serviceAccount:${var.project_id}.svc.id.goog[${var.k8s_namespace}/${var.k8s_service_account}]",
  ]
}
