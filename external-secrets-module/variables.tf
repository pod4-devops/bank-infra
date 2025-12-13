variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "cluster_name" {
  description = "The name of the EKS cluster"
  type        = string
  default     = "eks-cluster"
}

variable "secret_name" {
  description = "The name of the secret in AWS Secrets Manager"
  type        = string
  default     = "bank-app/db-credentials"
}

variable "namespace" {
  description = "Kubernetes namespace for External Secrets"
  type        = string
  default     = "external-secrets"
}

variable "external_secrets_operator_version" {
  description = "Version of External Secrets Operator to install"
  type        = string
  default     = "0.9.0"
}