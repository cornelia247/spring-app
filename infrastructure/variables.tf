variable "aws_region" {}
variable "project_name" {}
variable "env" {}
variable "vpc_cidr_block" {
    default = "10.16.0.0/16"
}
variable "pub_subnet_count" {}
variable "pub_cidr_block" {
  type = list(string)
}
variable "availability_zone" {
  type = list(string)
}
variable "pri_subnet_count" {}
variable "pri_cidr_block" {
  type = list(string)
}
variable "engine_version" {}
variable "cluster_version" {}
variable "instance_class" {}
variable "allocated_storage" {}
variable "db_username" {}
variable "db_name" {
  type = string
}
#backend
variable "s3_bucket" {}
variable "dynamodb_table" {}




# # EKS
variable "ondemand_instance_types" {}

variable "desired_capacity_on_demand" {}
variable "min_capacity_on_demand" {}
variable "max_capacity_on_demand" {}
variable "namespace" {
  type = string
  default = "default"
}
