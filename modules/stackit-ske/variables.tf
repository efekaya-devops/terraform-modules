variable "project_id" {
  description = "STACKIT project ID (UUID) the cluster is created in."
  type        = string

  validation {
    condition     = can(regex("^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$", var.project_id))
    error_message = "project_id must be a UUID."
  }
}

variable "name" {
  description = "Cluster name. SKE allows at most 11 characters: lowercase letters, digits and hyphens."
  type        = string

  validation {
    condition     = can(regex("^[a-z]([a-z0-9-]{0,9}[a-z0-9])?$", var.name))
    error_message = "name must be 1-11 chars, lowercase alphanumerics and hyphens, starting with a letter and not ending with a hyphen."
  }
}

variable "region" {
  description = "STACKIT region. eu01 is Germany (Frankfurt/Neckarsulm), EU-sovereign."
  type        = string
  default     = "eu01"
}

variable "kubernetes_version_min" {
  description = "Minimum Kubernetes version (major.minor). SKE patches within it; null picks the latest supported version."
  type        = string
  default     = null

  validation {
    condition     = var.kubernetes_version_min == null || can(regex("^1\\.[0-9]{2}(\\.[0-9]+)?$", var.kubernetes_version_min))
    error_message = "kubernetes_version_min must look like 1.33 or 1.33.4."
  }
}

variable "node_pools" {
  description = "Worker node pools. machine_type e.g. g2i.2 (2 vCPU/8 GB), g2i.4, g2i.8. Append new pools at the end: the provider matches by index."
  type = list(object({
    name               = string
    machine_type       = string
    minimum            = number
    maximum            = number
    availability_zones = optional(list(string), ["eu01-1"])
    volume_size        = optional(number, 50)
    volume_type        = optional(string, "storage_premium_perf1")
    labels             = optional(map(string), {})
    max_surge          = optional(number, 1)
    max_unavailable    = optional(number, 0)
  }))
  default = [{
    name         = "default"
    machine_type = "g2i.2"
    minimum      = 1
    maximum      = 2
  }]

  validation {
    condition     = length(var.node_pools) > 0
    error_message = "At least one node pool is required."
  }
  validation {
    condition     = alltrue([for p in var.node_pools : p.minimum >= 1 && p.maximum >= p.minimum])
    error_message = "Each node pool needs 1 <= minimum <= maximum."
  }
  validation {
    condition     = alltrue([for p in var.node_pools : can(regex("^[a-z][a-z0-9-]{0,14}$", p.name))])
    error_message = "Node pool names must be lowercase alphanumerics/hyphens, max 15 chars, starting with a letter."
  }
  validation {
    condition     = alltrue([for p in var.node_pools : alltrue([for z in p.availability_zones : can(regex("^eu01-[1-3m]$", z))])])
    error_message = "availability_zones must be eu01-1, eu01-2, eu01-3 or eu01-m."
  }
}

variable "maintenance_start" {
  description = "Start of the weekly maintenance window (RFC 3339 time, e.g. 02:00:00Z)."
  type        = string
  default     = "02:00:00Z"
}

variable "maintenance_end" {
  description = "End of the maintenance window."
  type        = string
  default     = "04:00:00Z"
}

variable "enable_kubernetes_version_updates" {
  description = "Let SKE auto-upgrade Kubernetes within the maintenance window."
  type        = bool
  default     = true
}

variable "enable_machine_image_version_updates" {
  description = "Let SKE auto-upgrade the node OS image within the maintenance window."
  type        = bool
  default     = true
}

variable "acl_allowed_cidrs" {
  description = "CIDRs allowed to reach the Kubernetes API. Empty list leaves the API open (non-prod only)."
  type        = list(string)
  default     = []

  validation {
    condition     = alltrue([for c in var.acl_allowed_cidrs : can(cidrnetmask(c))])
    error_message = "acl_allowed_cidrs must be valid IPv4 CIDRs."
  }
}

variable "dns_zones" {
  description = "Domain filters for the managed ExternalDNS extension. Empty disables the extension."
  type        = list(string)
  default     = []
}

variable "hibernation" {
  description = "Optional daily hibernation schedule (cron). Cuts cost for dev clusters."
  type = object({
    start    = string
    end      = string
    timezone = optional(string, "Europe/Berlin")
  })
  default = null
}

variable "create_kubeconfig" {
  description = "Also create a short-lived admin kubeconfig (sensitive output)."
  type        = bool
  default     = false
}

variable "kubeconfig_expiration" {
  description = "Kubeconfig lifetime in seconds."
  type        = number
  default     = 3600
}
