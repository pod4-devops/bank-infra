resource "aws_iam_policy" "deny_without_mfa" {
  name        = "DenyActionsWithoutMFA"
  description = "Deny all AWS actions when MFA is not present, except MFA setup and password change."

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "DenyAllActionsIfNoMFA"
        Effect = "Deny"

        # NotAction means "deny everything EXCEPT the listed actions"
        NotAction = [
          "iam:ChangePassword",
          "iam:GetAccountPasswordPolicy",
          "iam:GetUser",
          "iam:ListMFADevices",
          "iam:ListVirtualMFADevices",
          "iam:EnableMFADevice",
          "iam:DeactivateMFADevice",
          "iam:ResyncMFADevice",
          "sts:GetSessionToken"
        ]

        Resource = "*"

        Condition = {
          BoolIfExists = {
            "aws:MultiFactorAuthPresent" = "false"
          }
        }
      }
    ]
  })
}
