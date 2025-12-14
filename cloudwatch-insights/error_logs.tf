resource "aws_cloudwatch_query_definition" "error_logs" {
  name = "Bank55-Application-Errors"

  log_group_names = [
    var.log_group_name
  ]

  query_string = <<EOF
fields @timestamp, @message
| filter @message like /ERROR|Error|Exception/
| sort @timestamp desc
| limit 50
EOF
}
