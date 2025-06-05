resource "aws_eks_pod_identity_association" "cluster_autoscaler" {
  cluster_name    = var.cluster_name
  namespace       = var.cluster_name
  service_account = var.service_account
  role_arn        = var.role_arn
}
