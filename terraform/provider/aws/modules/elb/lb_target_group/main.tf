resource "aws_lb_target_group" "this" {
  name     = var.name
  port     = var.port
  protocol = var.protocol
  vpc_id   = var.vpc_id
  target_type = var.target_type

  health_check {
    path = var.health_check.path
    port = var.health_check.port
    healthy_threshold = var.health_check.healthy_threshold
    unhealthy_threshold = var.health_check.unhealthy_threshold
  }

  tags = var.tags

}