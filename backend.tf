terraform {
  backend "s3" {
    bucket         = "pod4bankapp-tfstate-bucket"
    key            = "root/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "pod4bankapp-tf-locks"
    encrypt        = true
  }
}
