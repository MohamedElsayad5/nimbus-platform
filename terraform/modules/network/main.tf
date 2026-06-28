# ------------------------------------------------------------------------------
# NETWORK MODULE
# Creates the VPC, Subnet with secondary ranges for GKE, and firewall rules.
#
# Design decisions:
#   - Single VPC with one regional subnet (dev environment; prod would use
#     multiple subnets per region for isolation).
#   - Secondary IP ranges are named and referenced by the GKE module. GKE
#     VPC-native clusters require secondary ranges — routes-based clusters
#     are legacy and not supported with private clusters.
#   - private_ip_google_access = true allows nodes (which have no external IP)
#     to reach Google APIs (Artifact Registry, Cloud Storage, etc.) via
#     Private Google Access — without going through Cloud NAT. This is
#     critical for cost and latency.
#   - Firewall rules follow least-privilege: only allow what is explicitly
#     needed. The GKE master needs to reach nodes on specific ports for
#     webhooks and metrics.
# ------------------------------------------------------------------------------

resource "google_compute_network" "vpc" {
  project                 = var.project_id
  name                    = var.network_name
  auto_create_subnetworks = false # We create subnets explicitly for full control

  # Routing mode REGIONAL means routes are only propagated within the region.
  # Use GLOBAL if you have multi-region VPCs (not needed for dev).
  routing_mode = "REGIONAL"

  description = "Nimbus Platform primary VPC network. Managed by Terraform."
}

resource "google_compute_subnetwork" "subnet" {
  project       = var.project_id
  name          = var.subnet_name
  region        = var.region
  network       = google_compute_network.vpc.id
  ip_cidr_range = var.subnet_cidr

  # Allows GKE nodes (which have no external IP) to reach Google APIs
  # such as Artifact Registry and Cloud Storage via internal routing.
  # Without this, nodes would need Cloud NAT even for Google services.
  private_ip_google_access = true

  # Flow logs capture VPC network traffic for security analysis and debugging.
  # Aggregation interval and sampling rate are tuned for cost efficiency.
  log_config {
    aggregation_interval = "INTERVAL_10_MIN"
    flow_sampling        = 0.05 # 5% sampling — sufficient for debugging, low cost
    metadata             = "INCLUDE_ALL_METADATA"
  }

  # Secondary ranges are required for VPC-native GKE clusters.
  # These names are referenced directly in the GKE module.
  secondary_ip_range {
    range_name    = var.pods_range_name
    ip_cidr_range = var.pods_cidr
  }

  secondary_ip_range {
    range_name    = var.services_range_name
    ip_cidr_range = var.services_cidr
  }
}

# ------------------------------------------------------------------------------
# FIREWALL RULES
# Minimal ruleset — GKE creates its own rules but we add these for safety.
# ------------------------------------------------------------------------------

# Allow the GKE control plane to reach nodes for:
#   - Webhooks (admission controllers): port 8443
#   - Metrics server: port 4443
#   - Kubelet API: port 10250
# Without this, features like HPA, VPA, and admission webhooks fail.
resource "google_compute_firewall" "allow_master_to_nodes" {
  project     = var.project_id
  name        = "${var.network_name}-allow-master-to-nodes"
  network     = google_compute_network.vpc.name
  description = "Allow GKE control plane to communicate with nodes for webhooks and metrics."
  direction   = "INGRESS"
  priority    = 1000

  source_ranges = [var.master_cidr]

  allow {
    protocol = "tcp"
    ports    = ["443", "4443", "8443", "10250", "10255"]
  }

  target_tags = ["gke-node"]
}

# Allow internal pod-to-pod and pod-to-service communication.
# This is needed for DNS (kube-dns), service mesh sidecars, and
# any cross-pod communication within the cluster.
resource "google_compute_firewall" "allow_internal" {
  project     = var.project_id
  name        = "${var.network_name}-allow-internal"
  network     = google_compute_network.vpc.name
  description = "Allow internal traffic within the VPC (nodes, pods, services)."
  direction   = "INGRESS"
  priority    = 1000

  source_ranges = [
    var.subnet_cidr,
    var.pods_cidr,
    var.services_cidr,
  ]

  allow {
    protocol = "tcp"
    ports    = ["0-65535"]
  }

  allow {
    protocol = "udp"
    ports    = ["0-65535"]
  }

  allow {
    protocol = "icmp"
  }
}

# Allow the GCP health check probers to reach your nodes.
# GCP Load Balancers use these specific source ranges to check backend health.
# Without this, your Ingress Load Balancer will show backends as UNHEALTHY.
resource "google_compute_firewall" "allow_health_checks" {
  project     = var.project_id
  name        = "${var.network_name}-allow-health-checks"
  network     = google_compute_network.vpc.name
  description = "Allow GCP Load Balancer health check probers to reach nodes."
  direction   = "INGRESS"
  priority    = 1000

  # These are Google's official health check prober IP ranges.
  # They are stable and documented in GCP docs.
  source_ranges = [
    "35.191.0.0/16",
    "130.211.0.0/22",
  ]

  allow {
    protocol = "tcp"
  }
}
