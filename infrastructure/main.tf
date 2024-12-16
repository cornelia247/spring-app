locals {
  env = var.env
  project = var.project_name
}
provider "kubernetes" {
  host    = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)


  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    args = [
      "eks",
      "get-token",
      "--cluster-name",
      module.eks.cluster_name
    ]
  }
}


#


provider "helm" {
  kubernetes {
    host                   = module.eks.cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      command     = "aws"
      args = [
        "eks",
        "get-token",
        "--cluster-name",
        module.eks.cluster_name
      ]
    }
  }
}


module "eks" {
  source = "./modules/eks" 
  cluster_version = var.cluster_version
  cluster_name                 = "${local.env}-${local.project}-cluster"
  env                          = local.env  
  desired_capacity_on_demand   = var.desired_capacity_on_demand
  min_capacity_on_demand       = var.min_capacity_on_demand
  max_capacity_on_demand       = var.max_capacity_on_demand
  ondemand_instance_types      = var.ondemand_instance_types
  private_subnets = module.vpc.private_subnet_ids
  project_name = local.project
  vpc_id = module.vpc.vpc_id



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
  eks_sg_name           = "${local.env}-${local.project}-eks-sg"
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
  private_subnet_ids= module.vpc.private_subnet_ids
  engine_version = var.engine_version
  instance_class = var.instance_class
  allocated_storage = var.allocated_storage
  db_username = var.db_username
  db_name =  var.db_name
}



module "alb" {
  source = "./modules/alb"
  env = var.env
  oidc_arn = module.eks.oidc_provider_arn
  oidc_url = module.eks.cluster_oidc_issuer_url
  cluster_name ="${local.env}-${local.project}-cluster"
  # project_name = var.project_name
  # cluster_version = module.eks.cluster_version
}
