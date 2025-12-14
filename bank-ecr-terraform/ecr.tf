resource "aws_ecr_repository" "bank_app_repo" {
  name                 = "bank-app-repo"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}
