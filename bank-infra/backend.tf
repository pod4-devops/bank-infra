terraform {
  required_version = ">= 1.10.0"

  backend "s3" {
    bucket       = "pod4bankapp-tfstate-bucket"   # must be created first
    key          = "envs/dev/terraform.tfstate"
    region       = "us-east-1"
    use_lockfile = true
  }
}

provider "aws" {
  region = "us-east-1"
}
