# Extract the OIDC provider URL
locals {
  oidc_provider = replace(data.aws_eks_cluster.selected.identity[0].oidc[0].issuer, "https://", "")
}

# Output the OIDC URL for verification
output "oidc_provider_url" {
  value = local.oidc_provider
}

output "cluster_name" {
  value = var.cluster_name
}

output "aws_account_id" {
  value = data.aws_caller_identity.current.account_id
}
