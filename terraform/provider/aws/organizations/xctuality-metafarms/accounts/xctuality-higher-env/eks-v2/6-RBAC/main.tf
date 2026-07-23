module "eks_rbac" {
  source = "../../../../modules/eks/access-entry"
  eks_cluster_name = var.eks_cluster_name

  access_entries = [
    {
        role = "admin"
        principal_arn = data.aws_iam_user.admin.arn
        kubernetes_groups = ["admin-group"]
    },
    {
        role = "developer"
        principal_arn = data.aws_iam_user.developer.arn
        kubernetes_groups = ["viewers"]
    }    
  
  ]
}