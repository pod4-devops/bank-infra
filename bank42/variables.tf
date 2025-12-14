variable "app_name" {
  description = "Name of the ArgoCD application"
  type        = string
  default     = "bank-app"
}

variable "repo_url" {
  description = "GitHub repository URL containing Kubernetes manifests"
  type        = string
  default     = "https://github.com/pod4-devops/bank-kubernetes-manifest"
}

variable "target_revision" {
  description = "Git branch, tag, or commit to sync from"
  type        = string
  default     = "HEAD"
}

variable "manifest_path" {
  description = "Path within the repository containing the manifests"
  type        = string
  default     = "bank-57-automation"
}

variable "destination_namespace" {
  description = "Kubernetes namespace where the application will be deployed"
  type        = string
  default     = "default"
}

variable "cluster_name" {
  description = "EKS cluster name"
  type        = string
  default     = "dev-test-eks"
}

variable "aws_region" {
  description = "AWS region where the EKS cluster is located"
  type        = string
  default     = "us-east-1"
}