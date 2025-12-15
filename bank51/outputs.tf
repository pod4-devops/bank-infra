output "namespace_name" {
  description = "Name of the monitoring namespace"
  value       = kubernetes_namespace.monitoring.metadata[0].name
}

output "storage_class_name" {
  description = "Name of the created storage class"
  value       = kubernetes_storage_class.prometheus_ebs.metadata[0].name
}

output "prometheus_pvc_name" {
  description = "Name of Prometheus server PVC"
  value       = kubernetes_persistent_volume_claim.prometheus_server.metadata[0].name
}

output "alertmanager_pvc_name" {
  description = "Name of Alertmanager PVC"
  value       = kubernetes_persistent_volume_claim.prometheus_alertmanager.metadata[0].name
}

output "storage_size" {
  description = "Prometheus storage size"
  value       = "${var.storage_size_gb}Gi"
}

output "retention_days" {
  description = "Prometheus retention period"
  value       = "${var.prometheus_retention_days} days"
}

output "cluster_name" {
  description = "EKS cluster name"
  value       = var.cluster_name
}
