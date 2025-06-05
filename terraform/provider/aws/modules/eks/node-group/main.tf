resource "aws_eks_node_group" "this" {
  cluster_name    = var.cluster_name
  version         = var.version
  node_group_name = var.node_group_name
  node_role_arn   = var.node_role_arn

  subnet_ids = var.subnet_ids

  capacity_type  = var.capacity_type
  instance_types = var.instance_types

  scaling_config {
    desired_size = var.scaling_config.desired_size
    max_size     = var.scaling_config.max_size
    min_size     = var.scaling_config.min_size
  }
  update_config {
    max_unavailable = 1
  }

  labels = {
    role = var.labels.role
  }

  lifecycle {
    ignore_changes = [scaling_config[0].desired_size]
  }
  tags = var.tags
}