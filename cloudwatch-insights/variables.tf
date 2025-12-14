variable "aws_region" {
  description = "AWS region to deploy CloudWatch resources"
  type        = string
  default     = "us-east-1"
}

variable "log_group_name" {
  description = "CloudWatch Log Group name"
  type        = string
}
