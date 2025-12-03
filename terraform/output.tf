output "dev_ou_id" {
  value = aws_organizations_organizational_unit.dev_ou.id
}

output "staging_ou_id" {
  value = aws_organizations_organizational_unit.staging_ou.id
}
