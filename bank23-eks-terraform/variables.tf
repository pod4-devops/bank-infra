variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "cluster_name" {
  type    = string
  default = "dev-test-eks"
}

variable "node_group_name" {
  type    = string
  default = "dev-eks-node-group"
}

