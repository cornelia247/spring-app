output "alb_hostname" {
    value = module.alb.alb_hostname
    description = "The URL to access your application"
  
}
output "ecs_task_execution_role_arn" {
    value = module.ecs.ecs_task_execution_role_arn
  
}
output "efs_file_system_id" {
    value = module.efs.efs_file_system_id
  
}
output "app_log_group" {
    value = module.cloudwatch.app_log_group
  
}
output "grafana_log_group" {
    value = module.cloudwatch.grafana_log_group
  
}
output "ecs_cluster_name" {
    value = module.ecs.ecs_cluster_name
  
}
output "ecs_app_service_name" {
    value = module.ecs.ecs_app_service_name
  
}
output "ecs_grafana_service_name" {
    value = module.ecs.ecs_grafana_service_name
  
}
output "efs_mount_target_ips" {
  value = module.efs.efs_mount_target_ips
}


