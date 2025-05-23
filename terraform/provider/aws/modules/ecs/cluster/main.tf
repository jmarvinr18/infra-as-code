resource "aws_ecs_cluster" "this" {
  name = var.app_cluster_name

  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}
