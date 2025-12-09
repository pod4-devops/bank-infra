data "aws_eks_cluster" "cluster" {
  name = var.cluster_name
}

data "aws_eks_node_group" "node_group" {
  cluster_name    = var.cluster_name
  node_group_name = var.node_group_name
}

data "aws_caller_identity" "current" {}

data "aws_iam_role" "node_role" {
  name = split("/", data.aws_eks_node_group.node_group.node_role_arn)[1]
}

resource "aws_iam_policy" "fluent_bit_cloudwatch" {
  name        = "FluentBitCloudWatchPolicy"
  description = "Policy for Fluent Bit to write logs to CloudWatch"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:DescribeLogStreams"
        ]
        Resource = "arn:aws:logs:${var.aws_region}:${data.aws_caller_identity.current.account_id}:log-group:${var.log_group_name}:*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "fluent_bit_cloudwatch" {
  policy_arn = aws_iam_policy.fluent_bit_cloudwatch.arn
  role       = data.aws_iam_role.node_role.name
}

resource "aws_cloudwatch_log_group" "kubernetes_logs" {
  name              = var.log_group_name
  retention_in_days = var.log_retention_days
}