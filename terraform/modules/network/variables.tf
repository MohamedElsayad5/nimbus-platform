variable "project_id" {
  description = "The GCP project ID where resources will be created."
  type        = string
}

variable "region" {
  description = "The GCP region for the subnet. The VPC itself is global."
  type        = string
}

variable "network_name" {
  description = "The name of the VPC network."
  type        = string
}

variable "subnet_name" {
  description = "The name of the primary subnet."
  type        = string
}

variable "subnet_cidr" {
  description = "The primary CIDR range for nodes. Recommend /20 (4096 IPs) for a dev cluster."
  type        = string
  default     = "10.0.0.0/20"
}

variable "pods_cidr" {
  description = <<-EOT
    Secondary IP range for GKE pods. Each node carves a /24 from this range.
    A /16 supports up to 256 nodes before exhaustion.
    Must not overlap with subnet_cidr or services_cidr.
  EOT
  type        = string
  default     = "10.1.0.0/16"
}

variable "services_cidr" {
  description = <<-EOT
    Secondary IP range for GKE Services (ClusterIP).
    A /20 provides 4096 service IPs — more than enough for any cluster.
    Must not overlap with subnet_cidr or pods_cidr.
  EOT
  type        = string
  default     = "10.2.0.0/20"
}

variable "pods_range_name" {
  description = "Named alias for the pods secondary range. Referenced by GKE cluster config."
  type        = string
  default     = "gke-pods"
}

variable "services_range_name" {
  description = "Named alias for the services secondary range. Referenced by GKE cluster config."
  type        = string
  default     = "gke-services"
}

variable "master_cidr" {
  description = <<-EOT
    CIDR for the GKE control plane (master) VPC peering.
    Must be a /28 (exactly 16 IPs — GCP requirement).
    Must not overlap with any other range in the VPC.
    This range is peered into your VPC but you cannot use it for workloads.
  EOT
  type        = string
  default     = "172.16.0.0/28"
}
