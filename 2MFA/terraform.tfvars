# AWS Configuration
aws_region = "us-east-1"

# Policy Settings
mfa_policy_name         = "RequireMFAPolicy"
mfa_required_group_name = "MFARequiredUsers"

# Specify which users need MFA (add your actual IAM usernames here)
users_requiring_mfa = [
  "devops-test-user",
]

# To apply to ALL users instead, uncomment the line below (remove the #)
# apply_to_all_users = true