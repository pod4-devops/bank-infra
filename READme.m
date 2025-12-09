 Fluent Bit DaemonSet Deployment
This deploys Fluent Bit as a DaemonSet to collect logs from all Kubernetes pods and send them to AWS CloudWatch.

Prerequisites
- AWS CLI configured
- kubectl configured for dev-test-eks cluster
- Terraform installed

Deployment Steps

1. Update `terraform.tfvars` with your node group name
2. Initialize Terraform:
```bash
   terraform init
```
3. Validate configuration:
```bash
   terraform validate
```
4. Deploy:
```bash
   terraform apply
```

Verification
```bash
kubectl get daemonset fluent-bit -n kube-system
kubectl get pods -n kube-system -l k8s-app=fluent-bit
kubectl logs -n kube-system -l k8s-app=fluent-bit --tail=50
```

Check CloudWatch: https://console.aws.amazon.com/cloudwatch/home?region=us-east-1#logsV2:log-groups/log-group/kubernetes-logs

Resources Created
- CloudWatch Log Group: kubernetes-logs
- IAM Policy: FluentBitCloudWatchPolicy
- Kubernetes ServiceAccount, ClusterRole, ClusterRoleBinding
- ConfigMap with Fluent Bit configuration
- DaemonSet running Fluent Bit on all nodes