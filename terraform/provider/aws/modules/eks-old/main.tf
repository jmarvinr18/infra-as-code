resource "aws_iam_role" "eks_cluster_role" {
  name = "${var.cluster_name}-role"

  # The policy  that grants an entity permission to assume the role.
  # Used to access AWS resources that you might not normally have access to.
  # The role that Amazon EKS will use to create AWS resources

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
        "Effect": "Allow",
        "Principal": {
            "Service": "eks.amazonaws.com"
        },
        "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "eks_cluster_role-AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks_cluster_role.name
}


resource "aws_eks_cluster" "eks_cluster" {
  name     = var.cluster_name
  version  = var.eks_cluster_version
  role_arn = aws_iam_role.eks_cluster_role.arn

  # public_access_cidrs     = ["0.0.0.0/0"]

  vpc_config {
    # endpoint_private_access = true
    # endpoint_public_access  = false
    subnet_ids = var.all_subnets
  }

  access_config {
    authentication_mode                         = "API"
    bootstrap_cluster_creator_admin_permissions = true
  }

  depends_on = [aws_iam_role_policy_attachment.eks_cluster_role-AmazonEKSClusterPolicy]
}


## turning off due to using the eks pod identity
## newly added for cluster autoscaler
# resource "aws_iam_role" "eks_cluster_autoscaler" {
#   assume_role_policy = data.aws_iam_policy_document.irsa.json
#   name = "eks_cluster_autoscaler"
# }


# resource "aws_iam_policy" "eks_cluster_autoscaler" { #ec2_cluster_node-ClusterAutoscalerPolicy
#   name = "${var.cluster_name}-cluster-auto-scaler"
#   description = "Policy for EKS Cluster Autoscaler"

#   policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Action = [
#             "autoscaling:DescribeAutoScalingGroups",
#             "autoscaling:DescribeAutoScalingInstances",
#             "autoscaling:DescribeLaunchConfigurations",
#             "autoscaling:DescribeTags",
#             "autoscaling:SetDesiredCapacity",
#             "autoscaling:TerminateInstanceInAutoScalingGroup",
#             "ec2:DescribeLaunchTemplateVersions"
#         ]
#         Effect   = "Allow"
#         Resource = "*"
#       },
#     ]
#   })
# }

# resource "aws_iam_role_policy_attachment" "eks_cluster_autoscaler_attach" {
#   role = aws_iam_role.eks_cluster_autoscaler.name
#   policy_arn = aws_iam_policy.eks_cluster_autoscaler.arn
# }

# resource "aws_iam_openid_connect_provider" "oidc_issuer" {
#   url             = aws_eks_cluster.eks_cluster.identity[0].oidc[0].issuer
#   thumbprint_list = [data.tls_certificate.eks.certificates[0].sha1_fingerprint]
#   client_id_list  = ["sts.amazonaws.com"]
# }
## newly added for cluster autoscaler
## turning off due to using the eks pod identity


## newly added for cluster autoscaler pod identitiy
resource "aws_eks_addon" "pod_identity" {
  cluster_name = aws_eks_cluster.eks_cluster.name
  addon_name = "eks-pod-identity-agent"
  addon_version = "v1.2.0-eksbuild-1"
}

resource "aws_iam_role" "cluster_autoscaler" {
  name = "${aws_eks_cluster.eks.name}-cluster-autoscaler"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "sts:AssumeRole",
          "sts:TagSession"
        ]
        Principal = {
          Service = "pods.eks.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "cluster_autoscaler" {
  policy_arn = aws_iam_policy.cluster_autoscaler.arn
  role = aws_iam_role.cluster_autoscaler.name
}

resource "aws_eks_pod_identity_association" "cluster_autoscaler" {
  cluster_name = aws_eks_cluster.eks.name
  namespace = "kube-system"
  service_account = "cluster-autoscaler"
  role_arn = aws_iam_role.cluster_autoscaler.arn
}

resource "helm_release" "cluster_autoscaler" {
  name = "autoscaler"

  repository = "https://kubernetes.github.io/autoscaler"
  chart = "cluster-autoscaler"
  namespace = "kube-system"
  version = "9.37.0"

  set {
    name = "rbac.serviceAccount.name"
    value = "cluster-autoscaler"
  }
  
  set {
    name = "autoDiscovery.clusterName"
    value = aws_eks_cluster.eks.name
  }

  set {
    name = "awsRegion"
    value = "ap-southeast-1"
  }

  depends_on = [helm_release.metrics_server]
}
## newly added for cluster autoscaler pod identitiy


## newly added for alb-controller
module "lb_role" {
  source    = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"

  role_name = "${var.cluster_name}_eks_lb_role"
  attach_load_balancer_controller_policy = true

  oidc_providers = {
    main = {
      provider_arn               = aws_iam_openid_connect_provider.oidc_issuer.arn
      namespace_service_accounts = ["kube-system:aws-load-balancer-controller"]
    }
  }

  depends_on = [ aws_eks_cluster.eks_cluster ]
}
## newly added for alb-controller