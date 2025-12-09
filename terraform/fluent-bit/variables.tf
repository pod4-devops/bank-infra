variable "aws_region" {
  description = "AWS region for CloudWatch"
  type        = string
  default     = "us-east-1"
}

variable "cluster_name" {
  description = "dev-test-eks"
  type        = string
}

variable "log_group_name" {
  description = "CloudWatch log group name"
  type        = string
  default     = "kubernetes-logs"
}

variable "log_retention_days" {
  description = "Number of days to retain logs"
  type        = number
  default     = 7
}

variable "fluent_bit_namespace" {
  description = "Kubernetes namespace for Fluent Bit"
  type        = string
  default     = "kube-system"
}

variable "node_group_name" {
  description = "dev-eks-node-group"
  type        = string
}|C