# ------------------------------------------------------------------------------
# ARTIFACT REGISTRY
# Stores Docker images for the platform.
#
# Why Artifact Registry over Docker Hub or GCR?
#   - Docker Hub has rate limits (100 pulls/6hr unauthenticated, 200 authenticated)
#     which cause pull failures in CI/CD pipelines.
#   - gcr.io (Container Registry) is being deprecated by Google. AR is the
#     successor and supports multi-format repositories (Docker, Maven, npm, etc.)
#   - AR is in the same region as your GKE cluster, so pulls are faster and
#     go over Google's private network (no egress cost from GKE to AR).
#   - Access is controlled by IAM, not separate credentials.
#
# Image cleanup policy:
#   We keep only the last 10 versions of each image. In a production pipeline
#   that deploys multiple times per day, unmanaged registries balloon in storage.
#   The cleanup policy runs automatically and deletes old untagged layers too.
# ------------------------------------------------------------------------------

resource "google_artifact_registry_repository" "nimbus" {
  project       = var.project_id
  location      = var.region
  repository_id = var.repository_id
  description   = "Nimbus Platform Docker image repository. Managed by Terraform."
  format        = "DOCKER"

  # Cleanup policy: automatically delete images to control storage costs.
  cleanup_policies {
    id     = "keep-last-10"
    action = "KEEP"

    most_recent_versions {
      # Keep the 10 most recent tagged versions of each image.
      # This preserves rollback capability (roughly 2 weeks at 1 deploy/day).
      keep_count = 10
    }
  }

  cleanup_policies {
    id     = "delete-old-untagged"
    action = "DELETE"

    condition {
      # Delete untagged images (intermediate build layers, failed pushes)
      # older than 7 days.
      tag_state  = "UNTAGGED"
      older_than = "604800s" # 7 days in seconds
    }
  }
}
