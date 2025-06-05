

output "cluster_endpoint" {
  value = aws_eks_cluster.eks_cluster.endpoint
}

output "cluster_certificate_authority_data" {
  value = aws_eks_cluster.eks_cluster.certificate_authority[0].data
}

output "aws_eks_cluster_auth_token" {
  value = data.aws_eks_cluster_auth.this.token
}

output "cluster_name" {
  value = aws_eks_cluster.eks_cluster.name
}

## newly added for cluster autoscaler
output "eks_cluster_autoscaler_arn" {
  value = aws_iam_role.eks_cluster_autoscaler.arn
}

## newly added for alb controller
output "eks_lb_role_arn" {
  value = module.lb_role.iam_role_arn
}