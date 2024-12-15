variable "project_name" {}
variable "private_subnet_ids" {
  type = list(string)
}
variable "engine_version" {}
variable "instance_class" {}
variable "allocated_storage" {}
variable "env" {}
variable "db_username" {}
variable "db_name" {
  type = string
}
