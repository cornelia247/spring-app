locals {
  env = var.env
  project = var.project_name
}

module "eks" {
  source = "./modules/eks"   

  cluster-name                 = "${local.env}-${local.project}-cluster"
  env                          = var.env
  is-eks-cluster-enabled       = true
  cluster-version              = var.cluster-version
  endpoint-private-access       = true
  endpoint-public-access        = false
  
  addons                       = var.addons
  
  desired_capacity_on_demand   = var.desired_capacity_on_demand
  min_capacity_on_demand       = var.min_capacity_on_demand
  max_capacity_on_demand       = var.max_capacity_on_demand
  ondemand_instance_types      = var.ondemand_instance_types

  # Network and IAM inputs:
  //NOT DONE
  eks_cluster_role_arn = module.iam.eks_cluster_role_arn
}



module "vpc" {
  source = "./module/vpc"

  cluster-name          = "${local.env}-${local.project}-cluster"
  cidr-block            = var.cidr_block
  vpc-name              ="${local.env}-${local.project}-vpc"
  env                   = var.env
  igw-name              = "${local.env}-${local.project}-igw"
  pub-subnet-count      = var.pub_subnet_count
  pub-cidr-block        = var.pub_cidr_block
  pub-availability-zone = var.pub_availability_zone
  pub-sub-name          = "${local.env}-${local.project}-pub-subnet"
  pri-subnet-count      = var.pri_subnet_count
  pri-cidr-block        = var.pri_cidr_block
  pri-availability-zone = var.pri_availability_zone
  pri-sub-name          = "${locals.env}-${local.project}-pri-subnet"
  public-rt-name        = "${local.env}-${local.project}-pub-rt"
  private-rt-name       = "${local.env}-${local.project}-pri-rt"
  eip-name              = "${local.env}-${local.project}-eip"
  ngw-name              = "${local.env}-${local.project}-ngw"
  eks-sg-name           = "${local.env}-${local.project}-eks-sg"
}


module "iam" {
  source = "./module/iam"

  cluster_name                = "${local.env}-${local.project}-cluster"
  is_eks_role_enabled         = true
  is_eks_nodegroup_role_enabled = true
}




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