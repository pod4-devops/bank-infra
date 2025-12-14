resource "aws_cloudwatch_query_definition" "http_5xx" {
  name = "Bank55-HTTP-5XX-Errors"

  log_group_names = [
    var.log_group_name
  ]

  query_string = <<EOF
fields @timestamp, status, path
| filter status >= 500
| sort @timestamp desc
| limit 30
EOF
}
