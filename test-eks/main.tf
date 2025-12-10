terraform {
  required_providers {
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.0"
    }
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}


# --- 1. THE MODULE CALL ---
module "eks" {
  source = "../modules/module-eks"

  environment  = "dev"
  cluster_name = "test-eks"

  # EKS cluster config
  eks_version = "1.32"

  # Node group config
  desired_size   = 2
  min_size       = 2
  max_size       = 4
  instance_types = ["t3.medium"]
  capacity_type  = "ON_DEMAND"
  ami_type       = "AL2_x86_64"
  label_one      = "system"

  # Required variables
  repository_name = "my-test-repo"
  domain-name     = "example.com"
  email           = "admin@example.com"

  # Subnets (Ensure these are your valid, non-1e subnets)
  public_subnet_ids = [
    "subnet-0ba6384682f2bce16",
    "subnet-013de8b4dd59cf38a"
  ]
  private_subnet_ids = [
    "subnet-0453633c89a001908",
    "subnet-089657d5476e369d2"
  ]
}
# <--- THIS CLOSING BRACE IS CRITICAL

# --- 2. DATA SOURCES ---
# We retrieve the cluster info *after* the module creates it
data "aws_eks_cluster" "target" {
  name = module.eks.cluster_name
}

data "aws_eks_cluster_auth" "target" {
  name = module.eks.cluster_name
}

# --- 3. HELM PROVIDER ---
# This tells Helm how to log in to the cluster
provider "helm" {
  kubernetes {
    host                   = data.aws_eks_cluster.target.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.target.certificate_authority[0].data)
    token                  = data.aws_eks_cluster_auth.target.token
  }
}