output "cluster_name" {
  value = stackit_ske_cluster.this.name
}

output "kubernetes_version_used" {
  description = "Full Kubernetes version SKE resolved from kubernetes_version_min."
  value       = stackit_ske_cluster.this.kubernetes_version_used
}

output "egress_address_ranges" {
  description = "Outbound IP ranges of the cluster; allow-list these at third parties."
  value       = stackit_ske_cluster.this.egress_address_ranges
}

output "kubeconfig" {
  description = "Short-lived admin kubeconfig (null unless create_kubeconfig = true)."
  value       = try(stackit_ske_kubeconfig.this[0].kube_config, null)
  sensitive   = true
}
