&nbsp; Terraform Bootstrap



This folder contains Terraform code to create the bootstrap resources for managing Terraform state:



\- **S3 Bucket**: Stores Terraform state remotely

\- **DynamoDB Table**: Provides state locking to prevent concurrent Terraform runs



These resources are used as the backend for all future Terraform deployments in this repository.



