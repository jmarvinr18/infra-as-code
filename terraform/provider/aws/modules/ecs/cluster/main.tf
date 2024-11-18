resource "aws_ecs_cluster" "this" {
  name = var.app_cluster_name

  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}

resource "aws_ecs_capacity_provider" "this" {
  name = var.asg_capacity_provider.name
        
  auto_scaling_group_provider {
    auto_scaling_group_arn = var.asg_capacity_provider.auto_scaling_group_arn
    managed_termination_protection = var.asg_capacity_provider.managed_termination_protection

    managed_scaling {
      maximum_scaling_step_size = var.asg_capacity_provider.managed_scaling.maximum_scaling_step_size
      minimum_scaling_step_size = var.asg_capacity_provider.managed_scaling.minimum_scaling_step_size
      status = var.asg_capacity_provider.managed_scaling.status
      target_capacity = var.asg_capacity_provider.managed_scaling.target_capacity
    }
  }
}

resource "aws_ecs_cluster_capacity_providers" "this" {
  
  cluster_name = aws_ecs_cluster.this.name
  capacity_providers = [aws_ecs_capacity_provider.this.name]

  default_capacity_provider_strategy {
    base              = 1
    weight            = 100
    capacity_provider = aws_ecs_capacity_provider.this.name
  }
}