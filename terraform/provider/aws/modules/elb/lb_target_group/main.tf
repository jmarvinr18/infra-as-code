resource "aws_lb_target_group" "this" {
  name     = var.name
  port     = var.port
  protocol = var.protocol
  vpc_id   = var.vpc_id

  health_check {
    path = var.health_check.path
    port = var.health_check.port
    healthy_threshold = var.health_check.healthy_threshold
    unhealthy_threshold = var.health_check.unhealthy_threshold
  }
}

resource "aws_lb_target_group_attachment" "this" {
  target_group_arn = aws_lb_target_group.this.arn
  target_id        = var.aws_instance_target_id
  port             = var.instance_target_group_port
}