
region = "ap-southeast-1"

eks_cluster_role_name = "eks-cluster-role"
eks_node_role_name = "eks-node-role"

eks_assume_role_policy = "./policies/eks-role-policy.json"

eks_nodes_assume_role_policy = "./policies/eks-nodes-role-policy.json"

tags = {
  "Name"        = "xctuality-higher-env-eks"
  "Environment" = "staging"
  "Release"     = "latest"
  "Created-by"  = "terraform-jmr"
}

eks_cluster_policy_attachments = ["arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"]

eks_node_policy_attachments = [
  "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy",
  "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy",
  "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
]

aws_lbc_policy_name = "AWSLoadBalancerControllerPolicy"

lbc_policy_file_name = "./policies/AWSLoadBalancerController.json"

eks_pods_service_file_name = "./policies/AWSEKSPodsService.json"
