resource "aws_ecs_cluster" "app_cluster_name" {
  name = var.app_cluster_name

  # setting {
  #   name  = "containerInsights"
  #   value = "enabled"
  # }
}

resource "aws_ecs_cluster_capacity_providers" "app_cluster_name" {
  
  cluster_name = aws_ecs_cluster.app_cluster_name.name
  capacity_providers = var.capacity_provider

  default_capacity_provider_strategy {
    base              = 1
    weight            = 100
    capacity_provider = "FARGATE"
  }
}