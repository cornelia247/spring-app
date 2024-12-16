data "http" "alb_policy" {
  url = "https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/main/docs/install/iam_policy.json"
}

resource "aws_iam_policy" "alb_iam_policy" {
  name   = "AWSLoadBalancerControllerIAMPolicy"
  policy = data.http.alb_policy.response_body
  tags = {
    "Environment"     = var.env
    terraform-managed = "true"
  }
}
data "aws_iam_policy_document" "aws_load_balancer_controller" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"

    condition {
      test     = "StringEquals"
      variable = "${replace(var.oidc_url, "https://", "")}:sub"
      values   = ["system:serviceaccount:kube-system:aws-load-balancer-controller"]
    }

    principals {
      identifiers = [var.oidc_arn]
      type        = "Federated"
    }
  }
}

resource "aws_iam_role" "aws_load_balancer_controller" {
  assume_role_policy = data.aws_iam_policy_document.aws_load_balancer_controller.json
  name               = "aws-load-balancer-controller"
}

resource "aws_iam_role_policy_attachment" "aws_load_balancer_controller" {
  role       = aws_iam_role.aws_load_balancer_controller.name
  policy_arn = aws_iam_policy.alb_iam_policy.arn
}


resource "helm_release" "aws_load_balancer_controller" {
  name       = "aws-load-balancer-controller"
  namespace  = "kube-system"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  version    = "1.5.0"
  cleanup_on_fail = true

  set {
    name  = "clusterName"
    value = var.cluster_name
  }


  set {
    name  = "serviceAccount.name"
    value = "aws-load-balancer-controller"
  }
  set {
    name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = aws_iam_role.aws_load_balancer_controller.arn
  }

}

# provider "kubernetes" {
#   host                   = data.aws_eks_cluster.cluster.endpoint
#   cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority[0].data)
#   token                  = data.aws_eks_cluster_auth.this.token
# }

# provider "helm" {
#   kubernetes {
#     host                   = data.aws_eks_cluster.cluster.endpoint
#     cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority[0].data)
#     token                  = data.aws_eks_cluster_auth.this.token
#   }
# }

# locals {

#   tags = {
#     Blueprint = var.cluster_name
#   }
# }

# data "aws_eks_cluster_auth" "this" {
#   name = var.cluster_name
# }

# data "aws_eks_cluster" "cluster" {
#   name = var.cluster_name
# }

# data "aws_region" "current" {}

# provider "bcrypt" {}


################################################################################
# Kubernetes Addons
################################################################################
# module "eks_blueprints_kubernetes_addons" {
#   source  = "aws-ia/eks-blueprints-addons/aws"
#   version = "~> 1.0"

#   cluster_name      = var.cluster_name
#   cluster_endpoint  = data.aws_eks_cluster.cluster.endpoint
#   cluster_version   = var.cluster_version
#   oidc_provider_arn = replace(data.aws_eks_cluster.cluster.identity[0].oidc[0].issuer, "https://", "") ## module.eks.oidc_provider_arn


#   # # Add-ons
#   # eks_addons = {
#   #   aws-ebs-csi-driver = {
#   #     most_recent = true
#   #   }
#   # }
#   # enable_aws_for_fluentbit            = true
#   # enable_aws_load_balancer_controller = false
#   # enable_aws_cloudwatch_metrics       = true
#   # enable_cert_manager                 = true
#   # enable_cluster_autoscaler           = true
#   # enable_metrics_server               = true
#   # enable_vpa                          = true
#   # enable_external_dns                 = true
#   # # eks_cluster_domain                    = var.domain_name
#   # # enable_calico                         = true
#   # # Let fluentbit create the cw log group
#   # # aws_for_fluentbit_create_cw_log_group = false
#   # tags = local.tags
# }


