locals {
  env = var.env
  project = var.project_name
}

module "eks" {
  source = "./modules/eks" 
  env = local.env
  project_name = local.project
  private_subnets = module.vpc.private_subnet_ids
  desired_size = var.desired_size
  max_size = var.max_size
  min_size = var.min_size
}

module "vpc" {
  source = "./modules/common"

  cluster_name          = "${local.env}-${local.project}-cluster"
  project_name = var.project_name
  cidr_block            = var.vpc_cidr_block
  vpc_name              ="${local.env}-${local.project}-vpc"
  env                   = var.env
  igw_name              = "${local.env}-${local.project}-igw"
  pub_subnet_count      = var.pub_subnet_count
  pub_cidr_block        = var.pub_cidr_block
  pub_sub_name          = "${local.env}-${local.project}-pub-subnet"
  pri_subnet_count      = var.pri_subnet_count
  pri_cidr_block        = var.pri_cidr_block
  availability_zone = var.availability_zone
  pri_sub_name          = "${local.env}-${local.project}-pri-subnet"
  public_rt_name        = "${local.env}-${local.project}-pub-rt"
  private_rt_name       = "${local.env}-${local.project}-pri-rt"
  eip_name              = "${local.env}-${local.project}-eip"
  ngw_name              = "${local.env}-${local.project}-ngw"
}

module "ecr" {
  source = "./modules/ecr"
  project_name = var.project_name
  env = var.env
  
}
module "database" {
  source = "./modules/database"
  project_name = var.project_name
  env = var.env
  private_subnet_ids = module.vpc.private_subnet_ids
  engine_version = var.engine_version
  instance_class = var.instance_class
  allocated_storage = var.allocated_storage
  db_username = var.db_username
  db_name =  var.db_name
  db_sg_id = module.vpc.db_sg_id
}


