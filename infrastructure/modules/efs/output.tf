output "efs_file_system_arn" {
  value = aws_efs_file_system.grafana.arn
}
output "efs_file_system_id" {
  value = aws_efs_file_system.grafana.id
}
# output "aws_efs_access_point_id" {
#   value = aws_efs_access_point.grafana.id
  
# }
output "efs_mount_target_ips" {
  value = aws_efs_mount_target.grafana.ip_address
  
}
