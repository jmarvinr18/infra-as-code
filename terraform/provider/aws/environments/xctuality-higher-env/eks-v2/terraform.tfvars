#### ROLE VALUES ####
eks_cluster_role_name = "eks-cluster-role"
eks_node_role_name    = "eks-node-role"

eks_assume_role_policy = "./policies/eks-role-policy.json"

eks_nodes_assume_role_policy = "./policies/eks-nodes-role-policy.json"


eks_cluster_policy_attachments = ["arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"]

eks_node_policy_attachments = [
  "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy",
  "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy",
  "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
]

aws_lbc_policy_name = "AWSEKSLoadBalancerControllerPolicy"

lbc_policy_file_name = "./policies/AWSLoadBalancerController.json"

eks_pods_service_file_name = "./policies/AWSEKSPodsService.json"

cluster_autoscaler_policy_file_name = "./policies/AWSEKSClusterAutoScalerPolicy.json"


#### NETWORK VALUES ####


cidr_block = "10.0.0.0/16"

enable_dns_hostnames = true
enable_dns_support   = true
domain               = "vpc"

subnets = [
  {
    cidr_block        = "10.0.0.0/19"
    availability_zone = "ap-southeast-1a"
    type              = "private"
    subnet_tags = {
      "Name"                                  = "staging-private-ap-southeast-1a"
      "kubernetes.io/role/internal-elb"       = "1"
      "kubernetes.io/cluster/staging-xct-eks" = "owned"
    }
  },
  {
    cidr_block        = "10.0.32.0/19"
    availability_zone = "ap-southeast-1b"
    type              = "private"
    subnet_tags = {
      "Name"                                  = "staging-private-ap-southeast-1b"
      "kubernetes.io/role/internal-elb"       = "1"
      "kubernetes.io/cluster/staging-xct-eks" = "owned"
    }
  },
  {
    cidr_block        = "10.0.64.0/19"
    availability_zone = "ap-southeast-1a"
    type              = "public"
    subnet_tags = {
      "Name"                                  = "staging-public-ap-southeast-1a"
      "kubernetes.io/role/elb"                = "1"
      "kubernetes.io/cluster/staging-xct-eks" = "owned"
    }
  },
  {
    cidr_block        = "10.0.96.0/19"
    availability_zone = "ap-southeast-1b"
    type              = "public"
    subnet_tags = {
      "Name"                                  = "staging-public-ap-southeast-1b"
      "kubernetes.io/role/elb"                = "1"
      "kubernetes.io/cluster/staging-xct-eks" = "owned"
    }
  }
]

route_tables = []


#### CLUSTER VALUES ####

eks_cluster_name = "xct-higher-eks"
eks_version      = "1.33"

vpc_config = {
  endpoint_private_access = false
  endpoint_public_access  = true
}

access_config = {
  authentication_mode                         = "API"
  bootstrap_cluster_creator_admin_permissions = true
}



#### NODE VALUES

node_group_name = "general"

capacity_type  = "ON_DEMAND"
instance_types = ["t3.medium"]

scaling_config = {
  desired_size = 1
  max_size     = 10
  min_size     = 1
}

update_config = {
  max_unavailable = 1
}
labels = {
  role = "general"
}


#### GLOBAL VALUES ####
region = "ap-southeast-1"

tags = {
  "Name"        = "xctuality-higher-env-eks"
  "Environment" = "staging"
  "Release"     = "latest"
  "Created-by"  = "terraform-jmr"
}


#### HELM CHART VALUES ####
helm_releases = [
  {
    helm_release_name = "aws-load-balancer-controller"
    helm_repository   = "https://aws.github.io/eks-charts"
    chart             = "aws-load-balancer-controller"
    namespace         = "kube-system"
    helm_version      = "1.8.1"
    set = [
      {
        name  = "clusterName"
        value = "aws_eks_cluster.eks.name"
      },
      {
        name  = "serviceAccount.name"
        value = "aws-load-balancer-controller"
      },
      {
        name  = "vpcId"
        value = "aws_vpc.main.id"
      },
    ]
  }
]
