region     = "ap-southeast-1"
eks_cluster_name = "xct-higher-eks"
# helm_releases = [ 
#   {
#       helm_release_name = "aws-load-balancer-controller"
#       helm_repository = "https://aws.github.io/eks-charts"
#       chart = "aws-load-balancer-controller"
#       namespace = "kube-system"
#       helm_version = "1.8.1"
#       set = [ 
#         {
#           name  = "clusterName"
#           value = "aws_eks_cluster.eks.name"
#         },
#         {
#           name  = "serviceAccount.name"
#           value = "aws-load-balancer-controller"
#         },        
#         {
#           name  = "vpcId"
#           value = "aws_vpc.main.id"
#         },
#       ]
#   } 
# ]



tags = {
  "Name"        = "xctuality-higher-env-eks"
  "Environment" = "staging"
  "Release"     = "latest"
  "Created-by"  = "terraform-jmr"
}
