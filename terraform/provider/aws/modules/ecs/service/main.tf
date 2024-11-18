resource "aws_ecs_service" "this" {
  name            = var.name
  cluster         = var.aws_ecs_cluster_id
  task_definition = var.aws_ecs_task_definition_arn
  desired_count   = var.desired_count
  iam_role        = var.iam_role_arn
  scheduling_strategy = var.scheduling_strategy
  force_new_deployment = var.force_new_deployment

  health_check_grace_period_seconds = 3600
  
  launch_type = var.launch_type

  # ordered_placement_strategy {
  #   type  = var.ordered_placement_strategy["type"]
  #   field = var.ordered_placement_strategy["field"]
  # }

  load_balancer {
    target_group_arn = var.target_group_arn
    container_name   = var.container_name
    container_port   = var.container_port
  }

  # placement_constraints {
  #   type       = "memberOf"
  #   expression = "attribute:ecs.availability-zone in [us-west-2a, us-west-2b]"
  # }
}