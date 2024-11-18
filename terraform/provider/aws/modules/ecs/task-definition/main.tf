
resource "aws_ecs_task_definition" "this" {
  family                   = var.app_task_family
  container_definitions    = file(var.container_definitions)
  requires_compatibilities = var.requires_compatibilities
  network_mode             = var.network_mode
  memory                   = var.memory
  cpu                      = var.cpu
  execution_role_arn       = var.execution_role_arn

  volume {
    name      = "service-storage"
    host_path = "/ecs/service-storage"
  }
}
