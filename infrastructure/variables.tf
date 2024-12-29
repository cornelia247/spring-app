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
variable "instance_class" {}
variable "allocated_storage" {}
variable "db_username" {}
variable "db_name" {
  type = string
}

variable "argocd_server_insecure" {
  type = bool
  default = true
}


variable "desired_size" {}
variable "min_size" {}
variable "max_size" {}



