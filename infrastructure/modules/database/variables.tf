variable "project_name" {}
variable "public_subnet_ids" {
  type = list(string)
}
# variable "private_subnet_ids" {
#   type = list(string)
# }
variable "engine_version" {}
variable "instance_class" {}
variable "allocated_storage" {}
variable "env" {}
variable "db_username" {}
variable "eks_sg_id" {}
variable "db_name" {
  type = string
}
