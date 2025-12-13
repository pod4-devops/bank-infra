# Get information about the EKS cluster
data "aws_eks_cluster" "selected" {
  name = var.cluster_name
}

# Get the OIDC provider URL from the cluster
data "aws_eks_cluster_auth" "selected" {
  name = var.cluster_name
}
