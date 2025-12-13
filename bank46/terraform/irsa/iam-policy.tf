# IAM Policy for Secrets Manager and SSM Parameter Store access
resource "aws_iam_policy" "secret_access" {
  name        = "Bank46-SecretAccess-Policy"
  description = "Policy for Bank46 project to access Secrets Manager and Parameter Store"
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret",
          "ssm:GetParameters",
          "ssm:GetParameter",
          "ssm:DescribeParameters"
        ]
        Resource = "*"
      }
    ]
  })
  
  tags = {
    Project     = "Bank46"
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

output "policy_arn" {
  value = aws_iam_policy.secret_access.arn
}
