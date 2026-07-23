##############################################################
##                     Service Creation                     ##
##############################################################


module "ecs-service" {
  source = "../../../../../modules/ecs/service"

  name                        = var.service_name
  aws_ecs_cluster_id          = data.aws_ecs_cluster.this.id
  aws_ecs_task_definition_arn = data.aws_ecs_task_definition.this.arn
  desired_count = var.desired_count
  scheduling_strategy = var.scheduling_strategy
  # iam_role_arn                = data.aws_iam_role.ServiceRoleForECS.arn




  target_group_arn = data.aws_lb_target_group.this.arn
  launch_type      = var.launch_type
  container_port   = var.container_port
  container_name   = var.container_name


  public_subnet_ids = data.aws_subnets.this.ids
  security_groups = data.aws_security_groups.this.ids
  tags = var.tags
}




##############################################################
##                    Auto Scaling                          ##
##############################################################
# "service/${aws_ecs_cluster.example.name}/${aws_ecs_service.example.name}"
module "ecs-autoscaling" {
  source = "../../../../../modules/app_autoscaling"

  min_capacity = var.min_capacity
  max_capacity = var.max_capacity
  aws_appautoscaling_policy_name = var.aws_appautoscaling_policy_name
  policy_type = var.policy_type
  resource_id = "service/${data.aws_ecs_cluster.this.cluster_name}/${var.service_name}"
  
}