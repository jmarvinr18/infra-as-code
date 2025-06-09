
module "oidc" {
  source = "../../../../modules/iam/openid_connect_provider"
  url = data.aws_eks_cluster.oidc.identity[0].oidc[0].issuer
  client_id_list = [ "sts.amazonaws.com" ]
  tags = var.tags
  
}


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