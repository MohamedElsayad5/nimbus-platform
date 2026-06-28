output "network_name" {
  description = "The name of the VPC network. Used by other modules to attach resources."
  value       = google_compute_network.vpc.name
}

output "network_id" {
  description = "The fully-qualified ID of the VPC network."
  value       = google_compute_network.vpc.id
}

output "network_self_link" {
  description = "The URI of the VPC. Required by some GCP resources instead of name."
  value       = google_compute_network.vpc.self_link
}

output "subnet_name" {
  description = "The name of the primary subnet."
  value       = google_compute_subnetwork.subnet.name
}

output "subnet_id" {
  description = "The fully-qualified ID of the subnet."
  value       = google_compute_subnetwork.subnet.id
}

output "subnet_self_link" {
  description = "The URI of the subnet. Required by GKE cluster configuration."
  value       = google_compute_subnetwork.subnet.self_link
}

output "subnet_cidr" {
  description = "The primary CIDR range of the subnet (node IPs)."
  value       = google_compute_subnetwork.subnet.ip_cidr_range
}

output "pods_range_name" {
  description = "The named secondary range for GKE pods. Referenced in GKE module."
  value       = var.pods_range_name
}

output "services_range_name" {
  description = "The named secondary range for GKE services. Referenced in GKE module."
  value       = var.services_range_name
}

output "master_cidr" {
  description = "The CIDR block used for the GKE control plane peering."
  value       = var.master_cidr
}
