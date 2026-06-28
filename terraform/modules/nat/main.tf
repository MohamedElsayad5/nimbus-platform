# ------------------------------------------------------------------------------
# CLOUD NAT
# Provides outbound internet connectivity for private GKE nodes.
#
# Why Cloud NAT instead of a NAT VM?
#   - Fully managed, no single point of failure
#   - Scales automatically with traffic
#   - No VM to patch, monitor, or resize
#   - Much cheaper than running a dedicated NAT instance
#
# IP allocation strategy:
#   AUTO_ONLY means GCP manages the public IPs. This is fine for outbound traffic
#   where you don't need a stable source IP. If you need a stable egress IP
#   (for IP allowlisting at third-party services), use MANUAL_ONLY with a
#   reserved static IP. For dev, AUTO_ONLY saves cost.
#
# Subnetwork scope:
#   ALL_SUBNETWORKS_ALL_IP_RANGES covers both primary node IPs and secondary
#   pod IPs. Without this, pods can't reach the internet, only nodes can.
# ------------------------------------------------------------------------------

resource "google_compute_router_nat" "nat" {
  project                            = var.project_id
  name                               = var.nat_name
  router                             = var.router_name
  region                             = var.region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
  min_ports_per_vm                   = var.min_ports_per_vm

  log_config {
    enable = true
    filter = var.log_filter
  }

  # TCP established connection idle timeout. Default is 1200s (20 min).
  # Reduced to 300s for faster cleanup of idle connections.
  tcp_established_idle_timeout_sec = 300

  # UDP idle timeout. 30s is the default and suitable for most workloads.
  udp_idle_timeout_sec = 30
}
