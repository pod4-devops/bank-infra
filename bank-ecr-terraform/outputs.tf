# Output the ECR repository URL
output "ecr_repository_url" {
  description = "The URL of the ECR repository"
  value       = aws_ecr_repository.bank_app_repo.repository_url
}

# Output the IAM Role ARN for CI/CD
output "ci_cd_role_arn" {
  description = "The ARN of the IAM role for CI/CD pipeline"
  value       = aws_iam_role.ci_cd_role.arn
}
