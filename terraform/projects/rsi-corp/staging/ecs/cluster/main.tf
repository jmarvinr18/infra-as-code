module "rsi-corp" {
  source           = "../../../../modules/aws/ecs/cluster"
  app_cluster_name = "test"
  
  capacity_provider = ["FARGATE"]
}
