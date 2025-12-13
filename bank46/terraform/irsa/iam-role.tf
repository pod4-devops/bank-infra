# Create IAM Role for IRSA
resource "aws_iam_role" "secret_access" {
  name = "Bank46-SecretAccess-Role"
  description = "IAM Role for Bank46 pods to access secrets via IRSA"
  
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/${local.oidc_provider}"
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "${local.oidc_provider}:sub": "system:serviceaccount:${var.namespace}:${var.service_account_name}"
            "${local.oidc_provider}:aud": "sts.amazonaws.com"
          }
        }
      }
    ]
  })
  
  tags = {
    Project     = "Bank46"
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

# Get current AWS account ID
data "aws_caller_identity" "current" {}

# Attach the policy to the role
resource "aws_iam_role_policy_attachment" "secret_access" {
  role       = aws_iam_role.secret_access.name
  policy_arn = aws_iam_policy.secret_access.arn
}

output "role_arn" {
  value = aws_iam_role.secret_access.arn
}

output "role_name" {
  value = aws_iam_role.secret_access.name
}
