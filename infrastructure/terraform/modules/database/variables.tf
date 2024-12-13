variable "prefix" {}
variable "vpc_id" {}
variable "subnet_ids" {
  type = list(string)
}
variable "db_username" {}
variable "db_password" {}