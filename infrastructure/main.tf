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


# provider "kubectl" {
#   host                   = module.eks-cluster.cluster_endpoint
#   cluster_ca_certificate = base64decode(module.eks-cluster.cluster_certificate_authority_data)
#   load_config_file       = false
#   exec {
#     api_version = "client.authentication.k8s.io/v1beta1"
#     command     = "aws"
#     args = [
#       "eks",
#       "get-token",
#       "--cluster-name",
#       module.eks.cluster_name
#     ]
#   }
# }


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
  # public_subnets = module.vpc.public_subnet_ids
  project_name = local.project
  # eks_sg_id = module.vpc.eks_sg_id
  vpc_id = module.vpc.vpc_id
  # service_account_name = "${local.env}-${local.project}-sa"
  # namespace = var.namespace


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
  cluster_name = module.eks.cluster_name
}
# module "iam" {
#   source = "./modules/iam"

#   cluster_name                = "${local.env}-${local.project}-cluster"
#   is_eks_role_enabled         = true
#   is_eks_nodegroup_role_enabled = true
# }




# module "eks" {
#   source = "../module"

#   env                   = var.env
#   cluster-name          = "${local.env}-${local.project}-${var.cluster-name}"
#   cidr-block            = var.vpc-cidr-block
#   vpc-name              = "${local.env}-${local.project}-${var.vpc-name}"
#   igw-name              = "${local.env}-${local.project}-${var.igw-name}"
#   pub-subnet-count      = var.pub-subnet-count
#   pub-cidr-block        = var.pub-cidr-block
#   pub-availability-zone = var.pub-availability-zone
#   pub-sub-name          = "${local.env}-${local.project}-${var.pub-sub-name}"
#   pri-subnet-count      = var.pri-subnet-count
#   pri-cidr-block        = var.pri-cidr-block
#   pri-availability-zone = var.pri-availability-zone
#   pri-sub-name          = "${local.env}-${local.project}-${var.pri-sub-name}"
#   public-rt-name        = "${local.env}-${local.project}-${var.public-rt-name}"
#   private-rt-name       = "${local.env}-${local.project}-${var.private-rt-name}"
#   eip-name              = "${local.env}-${local.project}-${var.eip-name}"
#   ngw-name              = "${local.env}-${local.project}-${var.ngw-name}"
#   eks-sg                = var.eks-sg

#   is_eks_role_enabled           = true
#   is_eks_nodegroup_role_enabled = true
#   ondemand_instance_types       = var.ondemand_instance_types
#   spot_instance_types           = var.spot_instance_types
#   desired_capacity_on_demand    = var.desired_capacity_on_demand
#   min_capacity_on_demand        = var.min_capacity_on_demand
#   max_capacity_on_demand        = var.max_capacity_on_demand
#   desired_capacity_spot         = var.desired_capacity_spot
#   min_capacity_spot             = var.min_capacity_spot
#   max_capacity_spot             = var.max_capacity_spot
#   is-eks-cluster-enabled        = var.is-eks-cluster-enabled
#   cluster-version               = var.cluster-version
#   endpoint-private-access       = var.endpoint-private-access
#   endpoint-public-access        = var.endpoint-public-access

#   addons = var.addons
# }