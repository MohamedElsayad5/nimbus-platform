# ------------------------------------------------------------------------------
# TERRAFORM REMOTE BACKEND
# Stores Terraform state in Google Cloud Storage.
#
# Why remote state?
#   - Local state is lost if your machine fails
#   - Team members can't collaborate with local state (conflicts)
#   - Remote state supports state locking: prevents two people running
#     terraform apply simultaneously (which corrupts state)
#
# The bucket must exist BEFORE running terraform init.
# Create it manually once:
#   gsutil mb -p PROJECT_ID -l REGION gs://BUCKET_NAME
#   gsutil versioning set on gs://BUCKET_NAME
#
# State locking in GCS uses Cloud Storage object locks (no extra cost).
# ------------------------------------------------------------------------------

terraform {
  backend "gcs" {
    # Replace these values with your actual project and bucket name.
    # These cannot use Terraform variables — they must be literals
    # or passed via -backend-config flags.
    bucket = "nimbus-terraform-state-nimbus-platform-500801"
    prefix = "terraform/environments/dev"
  }
}
