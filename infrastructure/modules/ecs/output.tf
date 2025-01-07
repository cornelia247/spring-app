output "ecs_cluster_name" {
  value = aws_ecs_cluster.main.name
}
output "ecs_app_service_name" {
  value = aws_ecs_service.app.name
}
output "ecs_grafana_service_name" {
  value = aws_ecs_service.grafana.name
}
output "ecs_task_execution_role_arn" {
  value = aws_iam_role.ecs_task_execution_role.arn
}
output "grafana_secret_name" {
  value = aws_secretsmanager_secret.this.name
  
}