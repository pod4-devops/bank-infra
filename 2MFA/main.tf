# ============================================================================
# AWS MFA Enforcement - Terraform Implementation
# ============================================================================

# Variables
# ============================================================================
variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "mfa_policy_name" {
  description = "Name of the MFA enforcement policy"
  type        = string
  default     = "RequireMFAPolicy"
}

variable "mfa_required_group_name" {
  description = "Name of the group that requires MFA"
  type        = string
  default     = "MFARequiredUsers"
}

variable "users_requiring_mfa" {
  description = "List of IAM users that require MFA"
  type        = list(string)
  default     = []
}

variable "apply_to_all_users" {
  description = "Apply MFA policy to all existing users"
  type        = bool
  default     = false
}

# Provider Configuration
# ============================================================================
terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# Data Sources
# ============================================================================
data "aws_caller_identity" "current" {}

data "aws_iam_users" "all" {
  count = var.apply_to_all_users ? 1 : 0
}

# IAM Policy Document - Strict MFA Enforcement
# ============================================================================
data "aws_iam_policy_document" "require_mfa" {
  # Deny all actions without MFA except MFA setup actions
  statement {
    sid    = "DenyAllExceptMFASetupWithoutMFA"
    effect = "Deny"

    not_actions = [
      "iam:CreateVirtualMFADevice",
      "iam:EnableMFADevice",
      "iam:GetUser",
      "iam:ListMFADevices",
      "iam:ListVirtualMFADevices",
      "iam:ResyncMFADevice",
      "sts:GetSessionToken",
      "iam:ChangePassword",
      "iam:GetAccountPasswordPolicy",
      "iam:GetAccountSummary",
      "iam:ListAccountAliases",
    ]

    resources = ["*"]

    condition {
      test     = "BoolIfExists"
      variable = "aws:MultiFactorAuthPresent"
      values   = ["false"]
    }
  }

  # Allow viewing account information
  statement {
    sid    = "AllowViewAccountInfo"
    effect = "Allow"

    actions = [
      "iam:GetAccountPasswordPolicy",
      "iam:GetAccountSummary",
      "iam:ListVirtualMFADevices",
      "iam:ListAccountAliases",
    ]

    resources = ["*"]
  }

  # Allow managing own passwords and access keys
  statement {
    sid    = "AllowManageOwnPasswordsAndAccessKeys"
    effect = "Allow"

    actions = [
      "iam:ChangePassword",
      "iam:GetUser",
      "iam:GetLoginProfile",
    ]

    resources = [
      "arn:aws:iam::${data.aws_caller_identity.current.account_id}:user/$${aws:username}"
    ]
  }

  # Allow managing own MFA devices
  statement {
    sid    = "AllowManageOwnMFADevices"
    effect = "Allow"

    actions = [
      "iam:CreateVirtualMFADevice",
      "iam:DeleteVirtualMFADevice",
      "iam:EnableMFADevice",
      "iam:ListMFADevices",
      "iam:ResyncMFADevice",
      "iam:DeactivateMFADevice",
    ]

    resources = [
      "arn:aws:iam::${data.aws_caller_identity.current.account_id}:mfa/$${aws:username}",
      "arn:aws:iam::${data.aws_caller_identity.current.account_id}:user/$${aws:username}",
    ]
  }
}

# IAM Policy - MFA Enforcement
# ============================================================================
resource "aws_iam_policy" "require_mfa" {
  name        = var.mfa_policy_name
  description = "Requires MFA authentication for all AWS actions"
  policy      = data.aws_iam_policy_document.require_mfa.json

  tags = {
    Name        = var.mfa_policy_name
    Purpose     = "Security"
    ManagedBy   = "Terraform"
    Description = "Enforces MFA for all user actions"
  }
}

# IAM Group for MFA Required Users
# ============================================================================
resource "aws_iam_group" "mfa_required" {
  name = var.mfa_required_group_name
  path = "/"
}

# Attach MFA Policy to Group
# ============================================================================
resource "aws_iam_group_policy_attachment" "mfa_enforcement" {
  group      = aws_iam_group.mfa_required.name
  policy_arn = aws_iam_policy.require_mfa.arn
}

# Add specified users to MFA required group
# ============================================================================
resource "aws_iam_group_membership" "mfa_required_users" {
  count = length(var.users_requiring_mfa) > 0 ? 1 : 0

  name  = "${var.mfa_required_group_name}-membership"
  group = aws_iam_group.mfa_required.name
  users = var.users_requiring_mfa
}

# Optional: Attach policy directly to all existing users
# ============================================================================
resource "aws_iam_user_policy_attachment" "mfa_all_users" {
  for_each = var.apply_to_all_users ? toset(data.aws_iam_users.all[0].names) : toset([])

  user       = each.value
  policy_arn = aws_iam_policy.require_mfa.arn
}

# Outputs
# ============================================================================
output "mfa_policy_arn" {
  description = "ARN of the MFA enforcement policy"
  value       = aws_iam_policy.require_mfa.arn
}

output "mfa_policy_id" {
  description = "ID of the MFA enforcement policy"
  value       = aws_iam_policy.require_mfa.id
}

output "mfa_required_group_name" {
  description = "Name of the MFA required group"
  value       = aws_iam_group.mfa_required.name
}

output "mfa_required_group_arn" {
  description = "ARN of the MFA required group"
  value       = aws_iam_group.mfa_required.arn
}

output "account_id" {
  description = "AWS Account ID where MFA policy is deployed"
  value       = data.aws_caller_identity.current.account_id
}

output "users_in_mfa_group" {
  description = "List of users added to MFA required group"
  value       = var.users_requiring_mfa
}