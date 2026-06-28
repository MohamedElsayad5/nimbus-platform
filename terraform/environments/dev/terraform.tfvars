# Copy this file to terraform.tfvars and fill in your actual values.
# NEVER commit terraform.tfvars to Git — it contains project-specific values.
# Add terraform.tfvars to .gitignore.

project_id     = "nimbus-platform-500801"
project_number = "582005187788"
zone           = "us-central1-a"
github_org     = "MohamedElsayad5"         
github_repo    = "nimbus-platform"

# Add your current public IP so you can reach the GKE API server.
authorized_networks = [
  {
    cidr_block   = "156.221.123.22/32"
    display_name = "my-workstation"
  },
  {
    cidr_block   = "35.235.240.0/20" # GCP Cloud Shell IPs
    display_name = "gcp-cloud-shell"
  }
]
