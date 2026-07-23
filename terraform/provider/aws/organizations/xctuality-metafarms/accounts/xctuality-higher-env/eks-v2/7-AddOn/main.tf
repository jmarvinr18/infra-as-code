module "eks_addon" {
  source = "../../../../modules/eks/add-on"
  eks_cluster_name = var.eks_cluster_name
  add_ons = var.add_ons
}