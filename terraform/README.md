# Terraform — Nimbus Platform Infrastructure

## Purpose

This directory contains all infrastructure-as-code for the Nimbus Platform, written in Terraform following HashiCorp best practices.

## Structure

```
terraform/
├── modules/                    # Reusable, independently testable modules
│   ├── network/                # VPC, Subnet, Firewall rules
│   ├── router/                 # Cloud Router (required by NAT)
│   ├── nat/                    # Cloud NAT (outbound internet for private nodes)
│   ├── gke/                    # GKE cluster + node pool
│   ├── artifact_registry/      # Docker image registry
│   ├── iam/                    # Workload Identity Federation (GitHub OIDC)
│   ├── service_accounts/       # GCP Service Accounts with least-privilege IAM
│   └── monitoring/             # GCS bucket for long-term metric storage
│
└── environments/
    └── dev/                    # Dev environment — calls modules with dev values
        ├── main.tf             # Module orchestration
        ├── variables.tf        # Input variable declarations
        ├── outputs.tf          # Useful outputs (cluster name, registry URL, etc.)
        ├── backend.tf          # Remote state in GCS
        ├── providers.tf        # Google provider configuration
        ├── versions.tf         # Pinned Terraform + provider versions
        └── terraform.tfvars.example
```

## Prerequisites

1. GCP project with billing enabled
2. `gcloud` CLI installed and authenticated
3. Terraform >= 1.7.0 installed
4. The following GCP APIs enabled:

```bash
gcloud services enable \
  container.googleapis.com \
  compute.googleapis.com \
  artifactregistry.googleapis.com \
  iam.googleapis.com \
  cloudresourcemanager.googleapis.com \
  iamcredentials.googleapis.com \
  sts.googleapis.com \
  storage.googleapis.com \
  logging.googleapis.com \
  monitoring.googleapis.com
```

## First-Time Setup

### Step 1: Create the Terraform state bucket (one time only)

```bash
export PROJECT_ID="your-gcp-project-id"
export REGION="us-central1"

# Create the bucket
gsutil mb -p $PROJECT_ID -l $REGION gs://nimbus-terraform-state-$PROJECT_ID

# Enable versioning (allows state rollback)
gsutil versioning set on gs://nimbus-terraform-state-$PROJECT_ID
```

### Step 2: Update backend.tf

Edit `environments/dev/backend.tf` and replace `REPLACE_WITH_PROJECT_ID` with your project ID.

### Step 3: Create terraform.tfvars

```bash
cd environments/dev
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with your values
```

### Step 4: Initialize and apply

```bash
cd environments/dev

terraform init
terraform validate
terraform plan -out=tfplan
terraform apply tfplan
```

### Step 5: Configure kubectl

After apply completes, run the output command:

```bash
# The exact command is printed by terraform output
terraform output get_credentials_command
# Run that command, which looks like:
gcloud container clusters get-credentials nimbus-cluster --zone us-central1-a --project YOUR_PROJECT_ID
```

Verify:
```bash
kubectl get nodes
kubectl get namespaces
```

## Destroy Infrastructure

```bash
cd environments/dev
terraform destroy
```

This removes all GCP resources. The GCS state bucket is NOT destroyed (by design).

## Cost Estimate

| Resource | Cost |
|---|---|
| GKE cluster (zonal, 1 free per account) | $0 |
| 2x e2-small nodes | ~$25/month |
| Cloud NAT | ~$1-3/month |
| Artifact Registry | ~$0.10/month |
| GCS (state + monitoring) | ~$0.05/month |
| **Total** | **~$28-30/month** |

With $300 GCP free credits: ~10 months free.

## Troubleshooting

**Error: API not enabled**
```
Error: googleapi: Error 403: ... is not enabled
```
Run the `gcloud services enable` commands in Prerequisites.

**Error: Insufficient permissions**
```
Error: Error creating cluster: googleapi: Error 403: Required permission
```
Ensure your GCP account has `roles/editor` or `roles/owner` on the project. For a personal dev project this is acceptable.

**Error: State lock**
```
Error: Error acquiring the state lock
```
Someone else (or a crashed previous run) holds the lock. Check if a previous apply is still running, then:
```bash
terraform force-unlock LOCK_ID
```

**GKE nodes NotReady after creation**
Wait 3-5 minutes. Nodes need to pull and start system pods (kube-dns, metrics-server, etc.).
