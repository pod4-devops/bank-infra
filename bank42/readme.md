# Bank 42 - Task 3.2.2: GitOps Configuration with ArgoCD

This folder contains Terraform configuration for managing ArgoCD applications that sync Kubernetes manifests from GitHub.

## Overview

**Task**: Configure GitOps tool (ArgoCD) to sync from the kubernetes-manifests repository

**Components**:
- ArgoCD is installed in the `dev-test-eks` EKS cluster
- ArgoCD Application syncs manifests from: `https://github.com/pod4-devops/bank-kubernetes-manifest`
- Manifest path: `bank-57-automation`
- Automatic sync with prune and self-heal enabled

## Prerequisites

1. AWS CLI configured with `devops-test-user` profile
2. kubectl configured to connect to `dev-test-eks` cluster
3. ArgoCD already installed in the cluster (in `argocd` namespace)
4. Access to the GitHub repository

## Files

- **`provider.tf`** - Kubernetes and kubectl provider configuration
- **`argocd-application.tf`** - ArgoCD Application resource definition
- **`variables.tf`** - Input variables for configuration
- **`backend.tf`** - S3 backend for Terraform state
- **`outputs.tf`** - Output values after deployment

## Setup Instructions

### 1. Set AWS Profile

```bash
export AWS_PROFILE=devops-test-user
```

### 2. Initialize Terraform

```bash
cd ~/TerraformProjects/bank-infra/bank42
terraform init
```

### 3. Review the Plan

```bash
terraform plan
```

### 4. Apply Configuration

```bash
terraform apply
```

This will create the ArgoCD Application resource that syncs your manifests.

## Accessing ArgoCD UI

### 1. Port Forward to ArgoCD Server

```bash
kubectl port-forward service/argocd-server -n argocd 8080:443
```

### 2. Get Admin Password

```bash
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
```

### 3. Open Browser

Navigate to: `http://localhost:8080`

**Login credentials**:
- Username: `admin`
- Password: (from step 2)

## How GitOps Works

1. **Developer pushes code** to the GitHub repository
2. **ArgoCD detects changes** (every 3 minutes by default)
3. **ArgoCD syncs automatically** with the cluster
4. **Self-heal enabled** - if someone manually changes the cluster, ArgoCD reverts it back to Git state
5. **Prune enabled** - if you delete something from Git, ArgoCD deletes it from the cluster

## Application Details

- **Application Name**: `bank-app`
- **Source Repository**: `https://github.com/pod4-devops/bank-kubernetes-manifest`
- **Target Branch**: `HEAD` (main/master)
- **Manifest Path**: `bank-57-automation`
- **Destination Namespace**: `default`
- **Sync Policy**: Automatic (prune + self-heal)

## Manifests Being Deployed

The `bank-57-automation` folder contains:
- `backendapi.yaml` - Backend API deployment
- `frontend.yaml` - Frontend deployment
- `bankend-service.yaml` - Backend service
- `frontend-service.yaml` - Frontend service
- `backend-ingress.yaml` - Ingress configuration
- `configmap.yaml` - Configuration
- `secret.yaml` - Secrets
- `alertmanager-config.yaml` - Monitoring
- `prometheus-rules.yaml` - Prometheus rules

## Verification

### Check ArgoCD Application Status

```bash
kubectl get application -n argocd
```

### Check Deployed Resources

```bash
kubectl get all -n default
```

### View ArgoCD Logs

```bash
kubectl logs -n argocd deployment/argocd-server
```

## Troubleshooting

### Application Not Syncing

1. Check ArgoCD application status:
   ```bash
   kubectl describe application bank-app -n argocd
   ```

2. Check if ArgoCD can access GitHub:
   ```bash
   kubectl logs -n argocd deployment/argocd-repo-server
   ```

### Authentication Issues

If you get "server has asked for client to provide credentials":

```bash
# Make sure you're using the right AWS profile
export AWS_PROFILE=devops-test-user

# Update kubeconfig
aws eks update-kubeconfig --name dev-test-eks --region us-east-1
```

## Cleanup

To remove the ArgoCD application (but keep ArgoCD itself):

```bash
terraform destroy
```

## Notes

- ArgoCD was installed using Helm (not Terraform) - see installation commands in team documentation
- This Terraform configuration only manages the ArgoCD Application resource
- State is stored in S3: `s3://digitalwitchngbucketcloud1/digitalwitchng/bank42/terraform.tfstate`

## Next Steps

After completing this task, you can:
1. Add more applications to ArgoCD
2. Configure notifications for sync events
3. Set up RBAC for team members
4. Integrate with CI/CD pipeline for automated deployments
