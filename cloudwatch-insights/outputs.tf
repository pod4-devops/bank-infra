output "saved_queries" {
  value = [
    aws_cloudwatch_query_definition.error_logs.name,
    aws_cloudwatch_query_definition.high_latency.name,
    aws_cloudwatch_query_definition.http_5xx.name,
    aws_cloudwatch_query_definition.pod_crashes.name
  ]
}
