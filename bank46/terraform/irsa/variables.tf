variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
  default     = "bank24-eks-cluster"  # Using existing cluster
}

variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "namespace" {
  description = "Kubernetes namespace for the service account"
  type        = string
  default     = "default"
}

variable "service_account_name" {
  description = "Name of the Kubernetes service account"
  type        = string
  default     = "bank46-secret-sa"  # Still bank46 for the project
}

variable "environment" {
  description = "Environment name for tagging"
  type        = string
  default     = "bank46-dev"
}
