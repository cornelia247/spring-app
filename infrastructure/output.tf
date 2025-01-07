output "alb_hostname" {
    value = module.alb.alb_hostname
    description = "The URL to access your application"
  
}
output "grafana_secret_name" {
  value = module.ecs.grafana_secret_name
}
