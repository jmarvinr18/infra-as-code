
module "eks_node_group" {
  source = "../../../../modules/eks/node-group"

  eks_version = var.eks_version
  cluster_name = var.eks_cluster_name

  node_group_name = var.node_group_name
  node_role_arn = data.aws_iam_role.node_role.arn

  subnet_ids = [
      data.aws_subnet.private_zone_1.id,
      data.aws_subnet.private_zone_2.id    
  ]


  labels = {
    role = var.labels.role
  }

  
  capacity_type  = var.capacity_type
  instance_types = var.instance_types

  update_config = {
    max_unavailable = var.update_config.max_unavailable
  }

  scaling_config = {
    desired_size = var.scaling_config.desired_size
    max_size = var.scaling_config.max_size
    min_size = var.scaling_config.min_size
  }

  tags = var.tags


}