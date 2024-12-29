output "oidc_provider_arn" {
  value = aws_iam_openid_connect_provider.oidc_provider.arn
}
output "endpoint" {
  description = "The endpoint of the EKS cluster"
  value       = aws_eks_cluster.main.endpoint
}

output "certificate_authority_data" {
  description = "The base64-encoded certificate data required to communicate with the cluster"
  value       = aws_eks_cluster.main.certificate_authority[0].data
}

output "cluster_name" {
  description = "The name of the EKS cluster"
  value       = aws_eks_cluster.main.name
}
output "cluster_id" {
  description = "id of the EKS cluster"
  value = aws_eks_cluster.main.cluster_id
}