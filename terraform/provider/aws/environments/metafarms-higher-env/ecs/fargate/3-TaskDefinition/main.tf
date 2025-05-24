##############################################################
##                  Task Definition Creation                ##
##############################################################

module "td" {
  source                = "../../../../../modules/ecs/task-definition"
  app_task_family       = var.td_name
  execution_role_arn    = data.aws_iam_role.ECSTaskExecutionRole.arn
  container_definitions = "${path.module}/task-definition.json"

  network_mode             = var.network_mode
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.cpu
  memory = var.memory
}

