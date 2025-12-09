module "eks_cluster" {
  source           = "./eks"
  cluster_name     = "bank23-eks"
  cluster_role_arn = "arn:aws:iam::ACCOUNT_ID:role/EKSClusterRole"
  node_group_name  = "bank23-ng"
  node_role_arn    = "arn:aws:iam::ACCOUNT_ID:role/EKSNodeRole"
  subnet_ids       = ["subnet-xxxx", "subnet-yyyy"]
}
