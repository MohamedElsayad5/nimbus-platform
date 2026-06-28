# ------------------------------------------------------------------------------
# GKE CLUSTER MODULE
# Creates a private, hardened GKE Standard cluster with a dedicated node pool.
#
# Architecture decisions:
#
# PRIVATE CLUSTER
#   Nodes have no public IPs. The control plane has a private endpoint inside
#   your VPC and a public endpoint restricted by authorized_networks. This is
#   the security baseline for any production cluster.
#
# ZONAL vs REGIONAL
#   Zonal = 1 control plane in 1 zone = $0 control plane cost (free tier).
#   Regional = 3 control planes across 3 zones = HA but 3x node minimum.
#   We use zonal for cost. This means cluster downtime during GKE upgrades
#   (~10 minutes, once per few months). Acceptable for dev/portfolio.
#
# WORKLOAD IDENTITY
#   Enabled at cluster level. Allows pods to call GCP APIs without key files.
#   This replaces the old metadata server approach which was a security hole
#   (any pod could get the node's service account token).
#
# SHIELDED NODES
#   Provides: Secure Boot, vTPM, Integrity Monitoring.
#   Protects against rootkit injection during node boot.
#   Zero cost, always enable.
#
# RELEASE CHANNEL
#   Subscribing to a release channel means GKE auto-upgrades your cluster
#   when new Kubernetes versions are available and tested by Google.
#   REGULAR channel is ~monthly, well-tested. Better than manually tracking versions.
#
# DEFAULT NODE POOL
#   We delete the default node pool immediately and create our own.
#   The default pool has no useful configuration options. Our custom pool
#   has named config, auto-repair, auto-upgrade, and proper service account.
# ------------------------------------------------------------------------------

resource "google_container_cluster" "primary" {
  project  = var.project_id
  name     = var.cluster_name
  location = var.zone # Zonal cluster (cheaper than regional)

  # We delete the default node pool and create a custom one.
  # This is a Terraform best practice for GKE — gives full control
  # over node pool configuration.
  remove_default_node_pool = true
  initial_node_count       = 1

  network    = var.network_name
  subnetwork = var.subnet_name

  # --- Network Configuration ---
  networking_mode = "VPC_NATIVE" # Required for private clusters; uses secondary ranges
  ip_allocation_policy {
    cluster_secondary_range_name  = var.pods_range_name
    services_secondary_range_name = var.services_range_name
  }

  # --- Private Cluster Configuration ---
  private_cluster_config {
    enable_private_nodes = true # Nodes get only private IPs

    # The control plane has a private IP in your VPC AND a public endpoint.
    # The public endpoint is restricted to authorized_networks below.
    # Set enable_private_endpoint = true to disable public endpoint entirely
    # (requires a VPN/bastion to access kubectl from outside).
    # For portfolio dev, we keep public endpoint with IP restriction.
    enable_private_endpoint = false

    master_ipv4_cidr_block = var.master_cidr
  }

  # Restrict who can reach the Kubernetes API server.
  master_authorized_networks_config {
    dynamic "cidr_blocks" {
      for_each = var.authorized_networks
      content {
        cidr_block   = cidr_blocks.value.cidr_block
        display_name = cidr_blocks.value.display_name
      }
    }
  }

  # --- Release Channel ---
  release_channel {
    channel = var.kubernetes_version
  }

  # --- Workload Identity ---
  # Format: PROJECT_ID.svc.id.goog
  # This enables pods to use GKE's metadata server to get GCP credentials.
  workload_identity_config {
    workload_pool = "${var.project_id}.svc.id.goog"
  }

  # --- Addons ---
  addons_config {
    # HTTP Load Balancing: creates GCP Load Balancers for Ingress resources.
    # Required for our GCE Ingress controller approach.
    http_load_balancing {
      disabled = false
    }

    # Horizontal Pod Autoscaler: required if you use HPA objects.
    horizontal_pod_autoscaling {
      disabled = false
    }

    # Network Policy: enables NetworkPolicy enforcement.
    # Without this, NetworkPolicy objects are created but have NO EFFECT.
    network_policy_config {
      disabled = false
    }

    # GCE Persistent Disk CSI Driver: required for PersistentVolumes on GCP.
    # Needed for Prometheus and Grafana persistent storage.
    gce_persistent_disk_csi_driver_config {
      enabled = true
    }
  }

  # --- Network Policy ---
  # Enables the network policy controller (Calico by default on GKE).
  network_policy {
    enabled  = true
    provider = "CALICO"
  }

  # --- Logging and Monitoring ---
  logging_config {
    enable_components = [
      "SYSTEM_COMPONENTS",
      "WORKLOADS",
    ]
  }

  monitoring_config {
    enable_components = [
      "SYSTEM_COMPONENTS",
    ]
    managed_prometheus {
      enabled = false # We run our own Prometheus — saves cost
    }
  }

  # --- Security ---
  # Binary Authorization: prevents deployment of images not signed by your
  # CI/CD pipeline. Disable for dev (complex setup), enable for production.
  binary_authorization {
    evaluation_mode = "DISABLED"
  }

  # Shielded nodes: Secure Boot + vTPM + Integrity Monitoring.
  # Protects against node-level attacks. Zero cost to enable.
  enable_shielded_nodes = true

  # --- Maintenance Window ---
  maintenance_policy {
    recurring_window {
      # Run maintenance on weekends (UTC) to minimize impact.
      start_time = "2024-01-06T02:00:00Z"
      end_time   = "2024-01-06T06:00:00Z"
      recurrence = "FREQ=WEEKLY;BYDAY=SA,SU"
    }
  }

  # Prevent accidental deletion of the cluster.
  deletion_protection = false # Set to true in production!

  lifecycle {
    ignore_changes = [
      # Ignore initial_node_count since we delete the default pool immediately.
      initial_node_count,
    ]
  }
}

# --- Custom Node Pool ---
resource "google_container_node_pool" "primary_nodes" {
  project    = var.project_id
  name       = "${var.cluster_name}-node-pool"
  location   = var.zone
  cluster    = google_container_cluster.primary.name
  node_count = var.node_count

  # Auto-repair: GKE automatically repairs unhealthy nodes.
  # Auto-upgrade: GKE upgrades nodes when control plane is upgraded.
  # Both should always be enabled. Disabling auto-upgrade means you
  # must manually track and apply node upgrades.
  management {
    auto_repair  = true
    auto_upgrade = true
  }

  upgrade_settings {
    # During upgrades, allow 1 extra node (surge upgrade strategy).
    # This means zero downtime: new node comes up, old one drains and terminates.
    max_surge       = 1
    max_unavailable = 0
  }

  node_config {
    machine_type = var.machine_type
    disk_size_gb = var.disk_size_gb
    disk_type    = "pd-standard" # Cheaper than pd-ssd; acceptable for dev

    service_account = var.node_sa_email

    # OAuth scopes: even though we use Workload Identity, nodes still need
    # these base scopes for cloud-platform access. The specific permissions
    # are controlled by IAM roles on the service account, not scopes.
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform",
    ]

    # Tags applied to node VMs. Used by firewall rules to target GKE nodes.
    tags = ["gke-node", var.cluster_name]

    # Labels on the node VMs (GCP resource labels, not Kubernetes labels).
    labels = {
      env     = "dev"
      project = "nimbus"
      managed = "terraform"
    }

    # Kubernetes node labels (different from GCP resource labels above).
    # Used for node selectors and affinity in pod specs.
    resource_labels = {
      env     = "dev"
      project = "nimbus"
    }

    # Workload Identity on nodes.
    workload_metadata_config {
      mode = "GKE_METADATA" # Intercept metadata requests, provide WI credentials
    }

    # Shielded instance config for this node pool.
    shielded_instance_config {
      enable_secure_boot          = true
      enable_integrity_monitoring = true
    }

    metadata = {
      # Disable legacy metadata endpoints. These are deprecated and a security risk.
      # The legacy endpoint allowed any pod to get the node's service account token.
      disable-legacy-endpoints = "true"
    }
  }
}
