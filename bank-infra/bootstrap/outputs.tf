output "s3_bucket_name" {
  description = "S3 Bucket used for Terraform state"
  value       = aws_s3_bucket.tf_state.bucket
}

output "dynamodb_table_name" {
  description = "DynamoDB Table used for Terraform locking"
  value       = aws_dynamodb_table.tf_locks.name
}
