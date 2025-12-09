aws_region              = "us-east-1"
mfa_policy_name         = "RequireMFAPolicy"
mfa_required_group_name = "MFARequiredUsers"

# Option A: Specify users explicitly
users_requiring_mfa = [
  "john.doe",
  "jane.smith",
  "admin.user"
]

# Option B: Apply to all existing users
# apply_to_all_users = true