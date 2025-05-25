resource "aws_appautoscaling_target" "this" {
  max_capacity       = var.max_capacity
  min_capacity       = var.min_capacity
  resource_id        = var.resource_id
  scalable_dimension = var.scalable_dimension
  service_namespace  = var.service_namespace
}

resource "aws_appautoscaling_policy" "this" {
  name               = var.aws_appautoscaling_policy_name
  policy_type        = var.policy_type
  resource_id        = aws_appautoscaling_target.this.resource_id
  scalable_dimension = aws_appautoscaling_target.this.scalable_dimension
  service_namespace  = aws_appautoscaling_target.this.service_namespace


  dynamic "step_scaling_policy_configuration" {
    for_each = var.policy_type == "StepScaling" ? [1] : []
    content {
      adjustment_type         = "ChangeInCapacity"
      cooldown                = 60
      metric_aggregation_type = "Maximum"

      step_adjustment {
        metric_interval_upper_bound = 0
        scaling_adjustment          = -1
      }
    }
  }

  dynamic "target_tracking_scaling_policy_configuration" {
    for_each = var.policy_type == "TargetTrackingScaling" ? [1] : []
    content {
        target_value = 70

        predefined_metric_specification {
            predefined_metric_type = "ECSServiceAverageCPUUtilization"
        }
        # customized_metric_specification {
        #     metric_name = "MyUtilizationMetric"
        #     namespace   = "MyNamespace"
        #     statistic   = "Average"
        #     unit        = "Percent"

        #     dimensions {
        #         name  = "MyOptionalMetricDimensionName"
        #         value = "MyOptionalMetricDimensionValue"
        #     }
        # }
    }
  }
}
