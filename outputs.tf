output "cloudwatch_log_group_name" {
  value = aws_cloudwatch_log_group.kubernetes_logs.name
}

output "cloudwatch_log_group_arn" {
  value = aws_cloudwatch_log_group.kubernetes_logs.arn
}

output "iam_policy_arn" {
  value = aws_iam_policy.fluent_bit_cloudwatch.arn
}

output "verification_commands" {
  value = <<-EOT
    kubectl get daemonset fluent-bit -n kube-system
    kubectl get pods -n kube-system -l k8s-app=fluent-bit
    kubectl logs -n kube-system -l k8s-app=fluent-bit --tail=50
  EOT
}