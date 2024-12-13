
output "private_subnet_ids" {
  value = aws_subnet.private-subnet[*].id
}
output "eks-sg-id" {
  value = aws_security_group.eks-cluster-sg.id
}