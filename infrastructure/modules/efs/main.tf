resource "aws_efs_file_system" "grafana" {
  creation_token = "${var.env}-${var.project_name}-grafana-efs"
  tags = {
    Name        = "${var.env}-${var.project_name}-grafana-efs"
    Project     = var.project_name
    Environment = var.env
  }
}

resource "aws_efs_mount_target" "grafana" {
  count          = length(var.private_subnets)
  file_system_id  = aws_efs_file_system.grafana.id
  subnet_id      = var.private_subnets[count.index]
  security_groups = [var.efs_sg_id]
}


# # EFS Access Point
# resource "aws_efs_access_point" "grafana" {
#   file_system_id = aws_efs_file_system.grafana.id

#   posix_user {
#     uid = 1000
#     gid = 1000
#   }

#   root_directory {
#     path = "/grafana"
#     creation_info {
#       owner_uid   = 1000
#       owner_gid   = 1000
#       permissions = "0755"
#     }
#   }
# }