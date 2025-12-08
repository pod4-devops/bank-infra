variable "region" {
  description = "AWS region for resources"
  type        = string
  default     = "us-east-1"
}

variable "bucket_name" {
  description = "S3 bucket name for Terraform state"
  type        = string
}

variable "key" {
  description = "S3 key/path for Terraform state file"
  type        = string
  default     = "envs/dev/terraform.tfstate"
}

variable "dynamodb_table_name" {
  description = "DynamoDB table name for Terraform state locking"
  type        = string
}
variable "aws_region" {
  description = "AWS region for resources"
  type        = string
  default     = "us-east-1"
}
