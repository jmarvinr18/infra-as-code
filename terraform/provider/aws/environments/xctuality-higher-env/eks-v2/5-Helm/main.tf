resource "aws_eks_pod_identity_association" "aws_lbc" {
  cluster_name    = var.eks_cluster_name
  namespace       = "kube-system"
  service_account = "aws-load-balancer-controller"
  role_arn        = data.aws_iam_role.lbc-role.arn
}



module "helm_release" {
  source = "../../../../modules/helm"

  helm_releases =  [ 
  {
      helm_release_name = "metrics-server"
      helm_repository = "https://kubernetes-sigs.github.io/metrics-server/"
      chart = "metrics-server"
      namespace = "kube-system"
      helm_version = "3.12.1"
      helm_values = [file("${path.module}/values/metrics-server.yaml")]
      set = [{
          name  = ""
          value = ""
      }]
  },       
  {
      helm_release_name = "autoscaler"
      helm_repository = "https://kubernetes.github.io/autoscaler"
      chart = "cluster-autoscaler"
      namespace = "kube-system"
      helm_version = "9.37.0"
      helm_values = [""]
      set = [ 
        {
          name  = "rbac.serviceAccount.name"
          value = "cluster-autoscaler"
        },
        {
          name  = "autoDiscovery.clusterName"
          value = var.eks_cluster_name
        },        
        {
          name  = "awsRegion"
          value = var.region
        },
      ]
  },    
  {
      helm_release_name = "aws-load-balancer-controller"
      helm_repository = "https://aws.github.io/eks-charts"
      chart = "aws-load-balancer-controller"
      namespace = "kube-system"
      helm_version = "1.8.1"
      helm_values = [""]
      set = [ 
        {
          name  = "clusterName"
          value = var.eks_cluster_name
        },
        {
          name  = "serviceAccount.name"
          value = "aws-load-balancer-controller"
        },        
        {
          name  = "vpcId"
          value = data.aws_vpc.eks.id
        },
      ]
  }
]

}