# ArgoCD Application Resource
# This manages the bank-app application in ArgoCD

resource "kubectl_manifest" "argocd_application" {
  yaml_body = <<-YAML
    apiVersion: argoproj.io/v1alpha1
    kind: Application
    metadata:
      name: ${var.app_name}
      namespace: argocd
    spec:
      project: default
      
      # Source - GitHub repository
      source:
        repoURL: ${var.repo_url}
        targetRevision: ${var.target_revision}
        path: ${var.manifest_path}
      
      # Destination - EKS cluster
      destination:
        server: https://kubernetes.default.svc
        namespace: ${var.destination_namespace}
      
      # Sync policy - Automatic with self-heal
      syncPolicy:
        automated:
          prune: true      # Delete resources that are no longer in Git
          selfHeal: true   # Auto-sync when cluster state drifts from Git
          allowEmpty: false
        syncOptions:
          - CreateNamespace=true
        retry:
          limit: 5
          backoff:
            duration: 5s
            factor: 2
            maxDuration: 3m
  YAML
}
