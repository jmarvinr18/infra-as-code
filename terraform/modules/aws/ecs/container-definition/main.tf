
resource "aws_ecs_task_definition" "app_task" {
  family                   = var.app_task_family
  container_definitions    = jsonencode(var.task_definition)
  requires_compatibilities = var.requires_compatibilities
  network_mode             = var.network_mode
  memory                   = var.memory
  cpu                      = var.cpu
  execution_role_arn       = var.ecs_task_execution_role_arn
}
