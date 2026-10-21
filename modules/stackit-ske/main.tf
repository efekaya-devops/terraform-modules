resource "stackit_ske_cluster" "this" {
  project_id             = var.project_id
  name                   = var.name
  region                 = var.region
  kubernetes_version_min = var.kubernetes_version_min

  node_pools = [for p in var.node_pools : {
    name               = p.name
    machine_type       = p.machine_type
    minimum            = p.minimum
    maximum            = p.maximum
    availability_zones = p.availability_zones
    volume_size        = p.volume_size
    volume_type        = p.volume_type
    labels             = p.labels
    max_surge          = coalesce(p.max_surge, length(p.availability_zones))
    max_unavailable    = p.max_unavailable
  }]

  maintenance = {
    enable_kubernetes_version_updates    = var.enable_kubernetes_version_updates
    enable_machine_image_version_updates = var.enable_machine_image_version_updates
    start                                = var.maintenance_start
    end                                  = var.maintenance_end
  }

  extensions = {
    acl = {
      enabled       = length(var.acl_allowed_cidrs) > 0
      allowed_cidrs = var.acl_allowed_cidrs
    }
    dns = {
      enabled = length(var.dns_zones) > 0
      zones   = var.dns_zones
    }
  }

  hibernations = var.hibernation == null ? null : [var.hibernation]
}

resource "stackit_ske_kubeconfig" "this" {
  count = var.create_kubeconfig ? 1 : 0

  project_id   = var.project_id
  cluster_name = stackit_ske_cluster.this.name
  region       = var.region
  expiration   = var.kubeconfig_expiration
  refresh      = true
}
