# EKS
variable "cluster-name" {}
variable "env" {}
variable "private-subnets" {}
variable "cluster-version" {}
variable "endpoint-private-access" {}
variable "endpoint-public-access" {}
variable "addons" {
  type = list(object({
    name    = string
    version = string
  }))
}
variable eks-sg-id {}
variable "ondemand_instance_types" {}
variable "desired_capacity_on_demand" {}
variable "min_capacity_on_demand" {}
variable "max_capacity_on_demand" {}
variable "eks_cluster_role_arn" {}
