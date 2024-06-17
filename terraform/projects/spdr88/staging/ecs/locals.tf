
locals {
  bucket_name = "cc-tf-demo"
  table_name  = "ccTfDemo"


  app_cluster_name               = "SPDR88-CLUSTER"
  availability_zones             = ["ap-east-1a", "ap-east-1b", "ap-east-1c"]
  app_task_family                = "app-task"
  repo_url                       = "905418407535.dkr.ecr.ap-east-1.amazonaws.com/spdr88-ecr-repo-2:latest"
  container_port                 = 4000
  app_task_name                  = "app-task"
  ecs_task_execution_role_name   = "app-task-execution-role"
  application_load_balancer_name = "spdr88-alb"
  target_group                   = "spdr88-tg"

  app_service_name = "spdr88-app-service"
}