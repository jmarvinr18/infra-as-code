region     = "ap-southeast-1"

node_group_name = "general"
eks_node_role_name = "eks-node-role"

capacity_type = "ON_DEMAND"
instance_types = ["t3.medium"]

scaling_config = {
    desired_size = 1
    max_size     = 10
    min_size     = 0
}

update_config = {
  max_unavailable = 1
}
labels = {
  role = "general"
}

tags = {
  "Name"        = "xctuality-higher-env-eks"
  "Environment" = "staging"
  "Release"     = "latest"
  "Created-by"  = "terraform-jmr"
}
