terraform {
  required_providers {
    null = {
      source  = "hashicorp/null"
      version = "~> 3.0"
    }
  }
}

# Build Backend Image with Git SHA and dev-latest tags
resource "null_resource" "build_backend_image" {
  triggers = {
    always_run = timestamp()
  }

  provisioner "local-exec" {
    command = <<-EOT
      cd "..\bank-backend"
      $GIT_SHA = git rev-parse --short HEAD
      docker build -t bank-backend:$GIT_SHA -t bank-backend:dev-latest .
      Write-Host "✅ Backend image built with tags: $GIT_SHA and dev-latest"
    EOT
    interpreter = ["PowerShell", "-Command"]
  }
}

# Build Frontend Image with Git SHA and dev-latest tags
resource "null_resource" "build_frontend_image" {
  triggers = {
    always_run = timestamp()
  }

  provisioner "local-exec" {
    command = <<-EOT
      cd "..\bank-frontend"
      $GIT_SHA = git rev-parse --short HEAD
      docker build -t bank-frontend:$GIT_SHA -t bank-frontend:dev-latest .
      Write-Host "✅ Frontend image built with tags: $GIT_SHA and dev-latest"
    EOT
    interpreter = ["PowerShell", "-Command"]
  }
}