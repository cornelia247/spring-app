output "app_log_group" {
  value = aws_cloudwatch_log_group.log_group.name
}
output "grafana_log_group" {
  value = aws_cloudwatch_log_group.grafana_log_group.name
}