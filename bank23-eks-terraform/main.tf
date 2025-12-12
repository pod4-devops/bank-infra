resource "aws_eks_cluster" "this" {
  name     = var.cluster_name
  role_arn = aws_iam_role.eks_cluster_role.arn
  version  = "1.28"

  vpc_config {
    subnet_ids            = data.aws_subnets.default_vpc.ids
    endpoint_public_access = true
  }

  tags = {
    Project = "Bank23"
    Owner   = "eaglewings"
  }
}

