output "argocd_application_name" {
  description = "Name of the ArgoCD application"
  value       = var.app_name
}

output "argocd_ui_url" {
  description = "URL to access ArgoCD UI (via port-forward)"
  value       = "http://localhost:8080"
}

output "github_repo" {
  description = "GitHub repository being synced"
  value       = var.repo_url
}

output "manifest_path" {
  description = "Path in repository being synced"
  value       = var.manifest_path
}

output "deployment_namespace" {
  description = "Kubernetes namespace where app is deployed"
  value       = var.destination_namespace
}