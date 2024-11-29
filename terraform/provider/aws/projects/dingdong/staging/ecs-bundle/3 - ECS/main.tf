##############################################################
##                     Cluster Creation                     ##
##############################################################

module "cluster" {
  source           = "../../../../../modules/ecs/cluster"
  app_cluster_name = var.app_cluster_name

  capacity_provider = var.capacity_provider

  capacity_provider_name = ""

  asg_capacity_provider = {
    name                           = var.asg_capacity_provider[0].name
    auto_scaling_group_arn         = data.aws_autoscaling_group.name.arn
    managed_termination_protection = var.asg_capacity_provider[0].auto_scaling_group_provider.managed_termination_protection

    managed_scaling = {
      maximum_scaling_step_size = var.asg_capacity_provider[0].auto_scaling_group_provider.managed_scaling.maximum_scaling_step_size
      minimum_scaling_step_size = var.asg_capacity_provider[0].auto_scaling_group_provider.managed_scaling.minimum_scaling_step_size

      status          = var.asg_capacity_provider[0].auto_scaling_group_provider.managed_scaling.status
      target_capacity = var.asg_capacity_provider[0].auto_scaling_group_provider.managed_scaling.target_capacity
    }
  }

  # depends_on = [ module.asg ]

}



##############################################################
##                  Task Definition Creation                ##
##############################################################

module "td" {
  source                = "../../../../../modules/ecs/task-definition"
  app_task_family       = var.td_name
  execution_role_arn    = data.aws_iam_role.ECSTaskExecutionRole.arn
  container_definitions = "${path.module}/task-definition.json"

  network_mode = var.network_mode
  requires_compatibilities = ["EC2"]
  cpu = 1024
}  


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

