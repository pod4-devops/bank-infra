resource "aws_cloudwatch_query_definition" "pod_crashes" {
  name = "Bank55-Pod-Crashes"

  log_group_names = [
    var.log_group_name
  ]

  query_string = <<EOF
fields @timestamp, kubernetes.pod_name, @message
| filter @message like /CrashLoopBackOff|OOMKilled/
| sort @timestamp desc
| limit 20
EOF
}
