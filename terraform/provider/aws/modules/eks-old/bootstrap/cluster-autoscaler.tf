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

  repository = local.cluster-autoscaler.chart_repo
  chart = local.cluster-autoscaler.chart_name
  namespace = local.cluster-autoscaler.namespace
  version = local.cluster-autoscaler.chart_version

  values = [templatefile("${path.module}/templates/${local.cluster-autoscaler.chart_name}.yaml.tpl", {
    sa_name                   = local.cluster-autoscaler.service_account,
    # role                      = module.cluster-autoscaler-irsa.iam_role_arn,
    region                    = var.region,
    cluster_name              = var.cluster_id,
    image_tag                 = local.cluster-autoscaler.image_tag,
    service_monitor_namespace = kubernetes_namespace.monitoring.metadata[0].name,
  })]

#   set {
#     name = "rbac.serviceAccount.name"
#     value = "cluster-autoscaler"
#   }
  
#   set {
#     name = "autoDiscovery.clusterName"
#     value = aws_eks_cluster.eks.name
#   }

#   set {
#     name = "awsRegion"
#     value = "ap-southeast-1"
#   }

  depends_on = [helm_release.metrics_server]
}