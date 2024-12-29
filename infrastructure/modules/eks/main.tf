locals {
  policies = [
    "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy", 
    "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy", 
    "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  ]
}


resource "aws_eks_cluster" "main" {
  name     = "${var.env}-${var.project_name}-cluster"
  role_arn = aws_iam_role.eks_cluster_role.arn

  vpc_config {
    subnet_ids = sort(var.private_subnets)
  }
  enabled_cluster_log_types = [
    "api", 
    "audit", 
    "authenticator", 
    "controllerManager", 
    "scheduler"
  ]

  tags = {
    Name = "${var.env}-${var.project_name}-cluster"
    Project = var.project_name
    Environment  = var.env
  }
}


resource "aws_eks_node_group" "main" {
  cluster_name    = aws_eks_cluster.main.name
  node_group_name = "${var.env}-${var.project_name}-node-group"
  node_role_arn   = aws_iam_role.eks_node_role.arn
  subnet_ids      = sort(var.private_subnets)

  scaling_config {
    desired_size = var.desired_size
    max_size     = var.max_size
    min_size     = var.min_size
  }

  tags = {
    Name = "${var.env}-${var.project_name}-node-group"
    Project = var.project_name
    Environment  = var.env
  }
}

resource "aws_iam_role" "eks_cluster_role" {
  name = "${var.env}-${var.project_name}-eks-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "eks.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF

  tags = {
    Name = "${var.env}-${var.project_name}-eks-role"
    Project = var.project_name
    Environment  = var.env
  }
}

resource "aws_iam_role_policy_attachment" "eks_cluster_role_attachment" {
  role       = aws_iam_role.eks_cluster_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

resource "aws_iam_role" "eks_node_role" {
  name = "${var.env}-${var.project_name}-node-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF

  tags = {
    Name = "${var.env}-${var.project_name}-node-role"
    Project = var.project_name
    Environment  = var.env
  }
}

resource "aws_iam_role_policy_attachment" "eks_role_attachment" {
  for_each   = toset(local.policies)
  role       = aws_iam_role.eks_node_role.name
  policy_arn = each.value
}

resource "aws_iam_openid_connect_provider" "oidc_provider" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = ["9e99a48a9960b14926bb7f3b2ab6a333b4d5f850"] 
  url             = aws_eks_cluster.main.identity[0].oidc[0].issuer
}










