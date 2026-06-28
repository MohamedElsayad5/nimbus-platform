variable "project_id" { type = string }
variable "region" { type = string }
variable "router_name" { type = string }
variable "nat_name" { type = string }

variable "min_ports_per_vm" {
  description = <<-EOT
    Minimum number of ports allocated per VM for NAT.
    Each port maps to one concurrent outbound connection.
    64 is sufficient for small clusters. Increase for high-traffic workloads.
    Higher values consume more NAT IP capacity.
  EOT
  type        = number
  default     = 64
}

variable "log_filter" {
  description = <<-EOT
    Which NAT translations to log. Options:
      ALL            - log every translation (expensive, use for debugging only)
      ERRORS_ONLY    - log only failed translations (recommended for production)
      TRANSLATIONS_ONLY - log successful only
    We use ERRORS_ONLY to catch connectivity issues without flooding logs.
  EOT
  type        = string
  default     = "ERRORS_ONLY"
}
