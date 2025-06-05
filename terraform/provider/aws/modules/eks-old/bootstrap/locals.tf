locals {
  cluster-autoscaler = merge({
    namespace       = "kube-system"
    service_account = "cluster-autoscaler"
    chart_version   = "9.37.0"
    chart_name      = "cluster-autoscaler"
    chart_repo      = "https://kubernetes.github.io/autoscaler"
    image_tag       = "1.29"
  }, var.cluster-autoscaler)

#   aws-node-termination-handler = merge({
#     namespace     = "kube-system"
#     chart_version = "0.15.3"
#     chart_name    = "aws-node-termination-handler"
#     chart_repo    = "https://aws.github.io/eks-charts"
#   }, var.aws-node-termination-handler)

#   aws-vpc-cni = merge({
#     namespace     = "kube-system"
#     chart_version = "1.1.10"
#     chart_name    = "aws-vpc-cni"
#     chart_repo    = "https://aws.github.io/eks-charts"
#   }, var.aws-vpc-cni)

  metrics-server = merge({
    namespace     = "kube-system"
    chart_version = "3.12.1"
    chart_name    = "metrics-server"
    chart_repo    = "https://kubernetes-sigs.github.io/metrics-server/"
  }, var.metrics-server)

#   prometheus-operator = merge({
#     chart_version = "20.0.1"
#     chart_name    = "kube-prometheus-stack"
#     chart_repo    = "https://prometheus-community.github.io/helm-charts"
#     replicas      = 1
#   }, var.prometheus-operator)

#   fluent-bit = merge({
#     chart_version = "0.19.7"
#     chart_name    = "fluent-bit"
#     chart_repo    = "https://fluent.github.io/helm-charts"
#   }, var.fluent-bit)
}
