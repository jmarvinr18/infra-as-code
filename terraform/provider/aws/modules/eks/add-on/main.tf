resource "aws_eks_addon" "this" {
  for_each = { for i, add_on in var.add_ons : i => add_on }

  cluster_name = var.eks_cluster_name

  addon_name = each.value.addon_name
  addon_version = each.value.addon_version

}