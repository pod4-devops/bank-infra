# monitoring.tf

terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.0"
    }
  }
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.cluster.token
}

provider "helm" {
  kubernetes {
    host                   = data.aws_eks_cluster.cluster.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority[0].data)
    token                  = data.aws_eks_cluster_auth.cluster.token
  }
}

# Data source to get your EKS cluster info
data "aws_eks_cluster" "cluster" {
  name = var.cluster_name
}

data "aws_eks_cluster_auth" "cluster" {
  name = var.cluster_name
}

# Create monitoring namespace
resource "kubernetes_namespace_v1" "monitoring" {
  metadata {
    name = "monitoring"
  }

  depends_on = [data.aws_eks_cluster.cluster]
}

# Deploy kube-prometheus-stack
resource "helm_release" "kube_prometheus_stack" {
  name             = "kube-prometheus-stack"
  repository       = "https://prometheus-community.github.io/helm-charts"
  chart            = "kube-prometheus-stack"
  namespace        = kubernetes_namespace_v1.monitoring.metadata[0].name
  version          = "65.1.0"
  create_namespace = false

  # Basic values configuration
  values = [
    yamlencode({
      prometheus = {
        prometheusSpec = {
          retention = "15d"
          resources = {
            requests = {
              cpu    = "100m"
              memory = "128Mi"
            }
            limits = {
              cpu    = "500m"
              memory = "512Mi"
            }
          }
        }
      }
      grafana = {
        adminPassword = "prom-operator"
        persistence = {
          enabled = false
        }
      }
    })
  ]

  depends_on = [kubernetes_namespace_v1.monitoring]
}

# Output Grafana access information
output "grafana_service_name" {
  value       = helm_release.kube_prometheus_stack.status
  description = "Grafana service status"
}

output "monitoring_namespace" {
  value       = kubernetes_namespace_v1.monitoring.metadata[0].name
  description = "Monitoring namespace"
}