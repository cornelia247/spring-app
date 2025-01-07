output "alb_hostname" {
  value = aws_alb.main.dns_name
}
output "alb_tg" {
  value = aws_alb_target_group.app.id
}

output "alb_grafana_tg" {
  value = aws_alb_target_group.grafana.id
}

