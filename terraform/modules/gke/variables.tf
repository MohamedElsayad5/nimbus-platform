variable "project_id" { type = string }
variable "region" { type = string }

variable "zone" {
  description = <<-EOT
    Single zone for the zonal cluster. Zonal clusters have one control plane
    in one zone. This is cheaper than regional clusters (3 control planes).
    For dev/learning, zonal is fine. For production, use regional.
  EOT
  type        = string
}

variable "cluster_name" {
  type    = string
  default = "nimbus-cluster"
}

variable "network_name" { type = string }
variable "subnet_name" { type = string }
variable "pods_range_name" { type = string }
variable "services_range_name" { type = string }
variable "master_cidr" { type = string }
variable "node_sa_email" { type = string }

variable "machine_type" {
  description = <<-EOT
    Machine type for GKE nodes.
    e2-small (2 vCPU, 2GB RAM) is the smallest that reliably runs GKE system
    pods + your application pods. e2-micro is too small — system pods alone
    consume ~600MB leaving almost nothing for workloads.
    e2-medium (2 vCPU, 4GB RAM) is recommended if budget allows.
  EOT
  type        = string
  default     = "e2-small"
}

variable "node_count" {
  description = "Number of nodes in the node pool. 2 nodes minimum to test PodAntiAffinity and PodDisruptionBudgets."
  type        = number
  default     = 2
}

variable "disk_size_gb" {
  description = "Boot disk size per node. 30GB is the minimum viable for GKE. Smaller causes disk pressure."
  type        = number
  default     = 30
}

variable "kubernetes_version" {
  description = "GKE release channel to use. REGULAR gets tested, stable versions ~monthly."
  type        = string
  default     = "REGULAR"
}

variable "authorized_networks" {
  description = <<-EOT
    List of CIDR blocks allowed to reach the GKE control plane API.
    For security, restrict this to your office/VPN IP or your CI/CD runner IPs.
    Never use 0.0.0.0/0 in production.
    For initial setup, you can add your current public IP.
  EOT
  type = list(object({
    cidr_block   = string
    display_name = string
  }))
  default = []
}
