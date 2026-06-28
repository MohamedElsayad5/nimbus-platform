# ------------------------------------------------------------------------------
# MONITORING MODULE
# Creates GCS bucket for long-term metric storage (Thanos/Prometheus remote write).
# For dev, we use in-cluster Prometheus with PersistentVolumes.
# This bucket is reserved for future Thanos integration (long-term storage).
# ------------------------------------------------------------------------------

resource "google_storage_bucket" "monitoring" {
  project                     = var.project_id
  name                        = var.bucket_name
  location                    = var.region
  storage_class               = "STANDARD"
  uniform_bucket_level_access = true
  force_destroy               = true # Allow terraform destroy to delete bucket with contents

  versioning {
    enabled = false # Metrics data doesn't need versioning
  }

  lifecycle_rule {
    action {
      type = "Delete"
    }
    condition {
      age = 30 # Delete metric data older than 30 days to control storage cost
    }
  }
}

# Grant the app service account access to write metrics to the bucket.
resource "google_storage_bucket_iam_member" "monitoring_writer" {
  bucket = google_storage_bucket.monitoring.name
  role   = "roles/storage.objectAdmin"
  member = "serviceAccount:${var.app_sa_email}"
}
