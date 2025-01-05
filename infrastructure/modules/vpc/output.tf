
output "private_subnet_ids" {
  value = aws_subnet.private_subnet[*].id
}
output "public_subnet_ids" {
  value = aws_subnet.public_subnet[*].id
}
output "db_sg_id" {
  value = aws_security_group.db.id
}
output "lb_sg_id" {
  value = aws_security_group.lb.id
}
output "ecs_sg_id" {
  value = aws_security_group.ecs_tasks.id
}
output "efs_sg_id" {
  value = aws_security_group.efs.id
}
output "vpc_id" {
  value = aws_vpc.vpc.id
  
}

