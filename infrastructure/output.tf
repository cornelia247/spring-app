output "alb_hostname" {
    value = module.alb.alb_hostname
    description = "The URL to access your application"
  
}
output "grafana_hostname" {
    value = "http://${module.alb.alb_hostname}:3000"
    description = "The URL to access Grafana"
  
}