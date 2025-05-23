##############################################################
##                     Service Creation                     ##
##############################################################


module "ecs-service" {
  source = "../../../../../modules/ecs/service"

  name                        = var.service_name
  aws_ecs_cluster_id          = module.cluster.id
  aws_ecs_task_definition_arn = module.td.arn
  iam_role_arn                = data.aws_iam_role.ServiceRoleForECS.arn

  target_group_arn = data.aws_lb_target_group.this.arn
  launch_type      = var.launch_type
  container_port   = var.container_port
  container_name   = var.container_name

  depends_on = [module.cluster, module.td]

}

