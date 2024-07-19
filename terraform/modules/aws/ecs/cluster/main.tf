resource "aws_ecs_cluster" "this" {
  name = var.app_cluster_name

  # setting {
  #   name  = "containerInsights"
  #   value = "enabled"
  # }
}

resource "aws_ecs_cluster_capacity_providers" "this" {
  
  cluster_name = aws_ecs_cluster.this.name
  capacity_providers = var.capacity_provider

  default_capacity_provider_strategy {
    base              = 1
    weight            = 100
    capacity_provider = "FARGATE"
  }
}