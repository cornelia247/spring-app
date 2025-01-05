locals {
  env = var.env
  project = var.project_name
}

module "ecs" {
  source = "./modules/ecs" 
  env = local.env
  aws_region = var.aws_region
  app_image =  var.app_image
  ecs_sg_id = module.vpc.ecs_sg_id  
  app_count = var.app_count
  fargate_cpu  = var.fargate_cpu
  fargate_memory       = var.fargate_memory
  db_credentials =  module.database.db_credentials
  app_port      = var.app_port
  private_subnets = module.vpc.private_subnet_ids
  project_name = local.project
  vpc_id = module.vpc.vpc_id
  ecs_task_execution_role_name = var.ecs_task_execution_role_name
  alb_tg = module.alb.alb_tg
  efs_file_system_arn = module.efs.efs_file_system_arn
  alb_grafana_tg = module.alb.alb_grafana_tg
  efs_file_system_id = module.efs.efs_file_system_id
  recovery_window = var.recovery_window

}


module "vpc" {
  source = "./modules/vpc"

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
  eks_sg_name           = "${local.env}-${local.project}-eks-sg"
  app_port = var.app_port
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
  recovery_window = var.recovery_window
}



module "alb" {
  source = "./modules/alb"
  env = var.env
  public_subnet_ids = module.vpc.public_subnet_ids
  vpc_id = module.vpc.vpc_id
  app_port = var.app_port
  project_name = var.project_name
  lb_sg_id = module.vpc.lb_sg_id
}

module "autoscaling" {
  env = local.env
  source = "./modules/autoscaling"
  ecs_service_name = module.ecs.ecs_app_service_name
  ecs_cluster_name = module.ecs.ecs_cluster_name
  min_capacity = var.min_capacity
  max_capacity = var.max_capacity
  project_name = local.project
  
}

module "cloudwatch" {
  source = "./modules/cloudwatch"
  env = local.env
  project_name = local.project
}
module "efs" {
  source = "./modules/efs"
  env = local.env
  project_name = local.project
  private_subnets = module.vpc.private_subnet_ids
  efs_sg_id = module.vpc.efs_sg_id
}