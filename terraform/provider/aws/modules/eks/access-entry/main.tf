resource "aws_eks_access_entry" "this" {
  for_each = { for i, entry in var.access_entries : i => entry }
#   for_each = { for i, policy in var.policy_attachments : i => policy}
  cluster_name = var.eks_cluster_name

  principal_arn = each.value.principal_arn

  kubernetes_groups = each.value.kubernetes_groups

}