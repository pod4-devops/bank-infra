provider "aws" {
  region = "us-east-1"
}

resource "aws_organizations_organizational_unit" "dev_ou" {
  name      = "Dev"
  parent_id = "r-d12v"
}

resource "aws_organizations_organizational_unit" "staging_ou" {
  name      = "Staging"
  parent_id = "r-d12v"
}
