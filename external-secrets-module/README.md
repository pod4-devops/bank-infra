External Secrets Setup for Bank Application

This folder contains the infrastructure code to sync AWS Secrets Manager secrets into your Kubernetes cluster using External Secrets Operator.

Overview

This setup allows your Kubernetes cluster to automatically fetch and sync secrets from AWS Secrets Manager without storing credentials in the cluster.

Files

 Terraform Files
-providers.tf` - AWS, Kubernetes, and Helm provider configurations
-variables.tf - Input variables for the setup
-terraform.tfvars - Variable values (cluster name, AWS region, secret name)
-external-secrets-iam.tf - Creates IAM role and policy for External Secrets Operator

 Kubernetes Manifests
-secretstore.yaml - Defines how to connect to AWS Secrets Manager
-externalsecret.yaml - Defines which secret to sync from AWS

Prerequisites

-EKS cluster running (e.g., `dev-test-eks`)
-External Secrets Operator already installed via Helm
-AWS CLI configured
-kubectl configured to access the cluster
-A secret in AWS Secrets Manager named `bank-app/db-credentials`

Setup Steps

1. Update Configuration

Edit `terraform.tfvars` to match your environment:

```hcl
aws_region           = "us-east-1"
cluster_name         = "dev-test-eks"
secret_name          = "bank-app/db-credentials"
namespace            = "external-secrets"
```

2. Deploy IAM Role (Terraform)

```bash
terraform init
terraform plan
terraform apply
```

This creates:
- IAM policy allowing access to AWS Secrets Manager
- IAM role for the External Secrets service account
- IRSA (IAM Roles for Service Accounts) trust relationship

3. Apply Kubernetes Manifests

```bash
kubectl apply -f secretstore.yaml
kubectl apply -f externalsecret.yaml
```

This creates:
-SecretStore: Connection configuration to AWS Secrets Manager
-ExternalSecret: Syncs the secret from AWS into the cluster

4. Verify the Setup

```bash
 Check if SecretStore is ready
kubectl get secretstore -n external-secrets

 Check if ExternalSecret is syncing
kubectl get externalsecret -n external-secrets

 Verify the synced secret was created
kubectl get secret bank-app-db-credentials -n external-secrets
kubectl get secret bank-app-db-credentials -n external-secrets -o yaml
```

How It Works

1. External Secrets Operator runs in your cluster
2. SecretStore tells it how to connect to AWS (using IRSA)
3. ExternalSecret specifies which secret to fetch
4. The operator automatically syncs the secret and creates a Kubernetes Secret
5. Your applications can mount this secret as a volume or environment variable

 Security Features

- ✅ No hardcoded AWS credentials in the cluster
- ✅ Uses IAM Roles for Service Accounts (IRSA)
- ✅ Automatic secret rotation (refresh every 1 hour)
- ✅ Secrets stored securely in AWS Secrets Manager

