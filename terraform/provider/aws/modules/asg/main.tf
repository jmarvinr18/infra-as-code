resource "aws_autoscaling_group" "this" {
  availability_zones = var.asg_availability_zones
  desired_capacity   = var.desired_capacity
  max_size           = var.max_size
  min_size           = var.min_size

  protect_from_scale_in = true

  launch_template {
    id      = var.launch_template.id
    version = var.launch_template.version
  }
}

# Create a new load balancer attachment
resource "aws_autoscaling_attachment" "this" {
  autoscaling_group_name = aws_autoscaling_group.this.id
#   elb                    = var.elb_id
  lb_target_group_arn = var.lb_target_group_arn
}

resource "aws_autoscaling_policy" "this" {
  name                   = "foobar3-terraform-test"
#   scaling_adjustment     = 4
  adjustment_type        = "ChangeInCapacity"
#   cooldown               = 300
  autoscaling_group_name = aws_autoscaling_group.this.name

  policy_type            = "TargetTrackingScaling"

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }

    target_value = 40.0
  }  
}