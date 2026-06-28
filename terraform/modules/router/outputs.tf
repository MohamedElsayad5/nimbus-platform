output "router_name" {
  description = "The name of the Cloud Router. Required by the NAT module."
  value       = google_compute_router.router.name
}

output "router_id" {
  value = google_compute_router.router.id
}
