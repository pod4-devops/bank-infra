resource "aws_cloudwatch_query_definition" "high_latency" {
  name = "Bank55-High-Latency"

  log_group_names = [
    var.log_group_name
  ]

  query_string = <<EOF
fields @timestamp, responseTime, path
| filter responseTime > 3000
| sort responseTime desc
| limit 20
EOF
}
