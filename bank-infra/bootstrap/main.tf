terraform {
  required_version = ">= 1.7.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "s3" {
    bucket         = "pod4bankapp-tfstate-bucket"
    key            = "global/s3/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "pod4bankapp-tf-locks"
    encrypt        = true
  }
}

provider "aws" {
  region = var.aws_region
}
