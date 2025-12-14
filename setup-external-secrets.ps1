# =========================================
# Fully Automated External Secrets Setup Script
# =========================================

# Variables
$ClusterName = "dev-test-eks"
$Region = "us-east-1"
$Namespace = "external-secrets"
$ServiceAccountName = "external-secrets-sa"
$PolicyName = "ESOReadSecretsPolicy"
$PolicyArn = "arn:aws:iam::245000192780:policy/$PolicyName"
$CFStackName = "eksctl-$ClusterName-addon-iamserviceaccount-$Namespace-$ServiceAccountName"

# Sample IAM policy document for External Secrets
$PolicyDocument = @"
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "secretsmanager:GetSecretValue",
                "secretsmanager:DescribeSecret"
            ],
            "Resource": "*"
        }
    ]
}
"@

# Step 1: Ensure namespace exists
Write-Host "Step 1: Checking namespace '$Namespace'..."
$ns = kubectl get namespace $Namespace --no-headers --ignore-not-found
if (-not $ns) {
    Write-Host "Namespace does not exist. Creating..."
    kubectl create namespace $Namespace
} else {
    Write-Host "Namespace exists."
}

# Step 2: Ensure IAM policy exists
Write-Host "`nStep 2: Checking IAM policy..."
try {
    aws iam get-policy --policy-arn $PolicyArn -ErrorAction Stop
    Write-Host "IAM policy exists."
} catch {
    Write-Host "IAM policy does NOT exist. Creating..."
    $tempFile = "$env:TEMP\$PolicyName.json"
    $PolicyDocument | Out-File -FilePath $tempFile -Encoding ascii
    aws iam create-policy --policy-name $PolicyName --policy-document file://$tempFile
    Remove-Item $tempFile
    Write-Host "IAM policy created."
}

# Step 3: Clean failed CloudFormation stacks
Write-Host "`nStep 3: Checking CloudFormation stack..."
try {
    $stackStatus = aws cloudformation describe-stacks --stack-name $CFStackName --query "Stacks[0].StackStatus" --output text 2>$null
    if ($stackStatus -match "FAILED|ROLLBACK_COMPLETE|ROLLBACK_FAILED") {
        Write-Host "Deleting failed stack..."
        aws cloudformation delete-stack --stack-name $CFStackName
        Write-Host "Waiting 30 seconds for deletion..."
        Start-Sleep -Seconds 30
    } else {
        Write-Host "No failed stack found."
    }
} catch {
    Write-Host "No existing stack found."
}

# Step 4: Associate IAM OIDC provider
Write-Host "`nStep 4: Associating IAM OIDC provider..."
try {
    eksctl utils associate-iam-oidc-provider --region $Region --cluster $ClusterName --approve
} catch {
    Write-Warning "OIDC provider may already exist."
}

# Step 5: Create IAM Service Account
Write-Host "`nStep 5: Creating IAM Service Account..."
eksctl create iamserviceaccount `
    --cluster $ClusterName `
    --namespace $Namespace `
    --name $ServiceAccountName `
    --attach-policy-arn $PolicyArn `
    --approve `
    --override-existing-serviceaccounts

Write-Host "`n✅ Done! IAM Service Account '$ServiceAccountName' is ready in namespace '$Namespace'."
