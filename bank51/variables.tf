variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"
}

variable "cluster_name" {
  description = "Existing EKS cluster name"
  type        = string
  default     = "bank24-eks-cluster"
}

variable "namespace" {
  description = "Kubernetes namespace for Prometheus"
  type        = string
  default     = "monitoring"
}

variable "storage_class_name" {
  description = "Name for the storage class"
  type        = string
  default     = "prometheus-ebs"
}

variable "prometheus_retention_days" {
  description = "How many days to retain Prometheus metrics"
  type        = number
  default     = 15
}

variable "storage_size_gb" {
  description = "Storage size in GB for Prometheus"
  type        = number
  default     = 20
}
