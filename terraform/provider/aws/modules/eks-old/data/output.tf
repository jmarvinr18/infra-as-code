output "cluster" {
  value = data.aws_eks_cluster.this
}

output "cluster_endpoint" {
  value = data.aws_eks_cluster.this.endpoint
}

output "cluster_certificate_authority_data" {
  value = data.aws_eks_cluster.this.certificate_authority[0].data
}

output "aws_eks_cluster_auth_token" {
  value = data.aws_eks_cluster_auth.this.token
}