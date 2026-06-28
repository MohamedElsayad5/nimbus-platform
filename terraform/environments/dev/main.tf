# ------------------------------------------------------------------------------
# NIMBUS PLATFORM — DEV ENVIRONMENT
# Orchestrates all infrastructure modules.
#
# Dependency order (Terraform resolves this via the dependency graph):
#   service_accounts → (no deps)
#   network          → (no deps)
#   router           → network
#   nat              → router
#   artifact_registry → (no deps)
#   iam              → service_accounts
#   gke              → network, service_accounts
#   monitoring       → service_accounts
# ------------------------------------------------------------------------------

# --- Service Accounts (no dependencies — create first) ---
module "service_accounts" {
  source     = "../../modules/service_accounts"
  project_id = var.project_id
}

# --- VPC Network ---
module "network" {
  source       = "../../modules/network"
  project_id   = var.project_id
  region       = var.region
  network_name = "nimbus-vpc"
  subnet_name  = "nimbus-subnet"
}

# --- Cloud Router (depends on network) ---
module "router" {
  source       = "../../modules/router"
  project_id   = var.project_id
  region       = var.region
  network_name = module.network.network_name
  router_name  = "nimbus-router"
}

# --- Cloud NAT (depends on router) ---
module "nat" {
  source      = "../../modules/nat"
  project_id  = var.project_id
  region      = var.region
  router_name = module.router.router_name
  nat_name    = "nimbus-nat"
}

# --- Artifact Registry ---
module "artifact_registry" {
  source     = "../../modules/artifact_registry"
  project_id = var.project_id
  region     = var.region
}

# --- IAM: Workload Identity Federation ---
module "iam" {
  source          = "../../modules/iam"
  project_id      = var.project_id
  project_number  = var.project_number
  github_org      = var.github_org
  github_repo     = var.github_repo
  cicd_sa_email   = module.service_accounts.cicd_sa_email
  app_sa_email    = module.service_accounts.app_sa_email
}

# --- GKE Cluster (depends on network + service accounts) ---
module "gke" {
  source              = "../../modules/gke"
  project_id          = var.project_id
  region              = var.region
  zone                = var.zone
  network_name        = module.network.network_name
  subnet_name         = module.network.subnet_name
  pods_range_name     = module.network.pods_range_name
  services_range_name = module.network.services_range_name
  master_cidr         = module.network.master_cidr
  node_sa_email       = module.service_accounts.gke_node_sa_email
  authorized_networks = var.authorized_networks

  depends_on = [module.nat] # Ensure NAT is ready before cluster nodes boot
}

# --- Monitoring Bucket ---
module "monitoring" {
  source       = "../../modules/monitoring"
  project_id   = var.project_id
  region       = var.region
  bucket_name  = "nimbus-monitoring-${var.project_id}"
  app_sa_email = module.service_accounts.app_sa_email
}
