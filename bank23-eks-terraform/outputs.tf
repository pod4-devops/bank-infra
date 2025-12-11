output "cluster_name" {
  value = aws_eks_cluster.this.name
}

output "cluster_endpoint" {
  value = aws_eks_cluster.this.endpoint
}

output "node_group_arns" {
  value = aws_eks_node_group.managed_nodes.arn
}

