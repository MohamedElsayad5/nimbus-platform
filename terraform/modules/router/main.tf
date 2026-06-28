# ------------------------------------------------------------------------------
# CLOUD ROUTER
# Cloud Router is the BGP routing infrastructure that Cloud NAT sits on top of.
# It is a regional resource — one per region per VPC.
# Even though we're not using BGP peering with on-premises networks here,
# Cloud NAT requires a Cloud Router to function.
# ------------------------------------------------------------------------------

resource "google_compute_router" "router" {
  project     = var.project_id
  name        = var.router_name
  region      = var.region
  network     = var.network_name
  description = "Cloud Router for Nimbus Platform. Used by Cloud NAT for outbound internet access."

  bgp {
    # ASN (Autonomous System Number) for BGP. For Cloud NAT-only usage,
    # this value doesn't matter but must be set. 64512 is a common private ASN.
    asn = 64512
  }
}
