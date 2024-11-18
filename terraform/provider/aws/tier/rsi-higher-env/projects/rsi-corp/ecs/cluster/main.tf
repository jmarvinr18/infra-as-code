module "rsi-corp" {
  source           = "../../../../../../modules/ecs/cluster"
  app_cluster_name = var.app_cluster_name
  
  capacity_provider = var.capacity_provider
}
