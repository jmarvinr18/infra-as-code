resource "aws_lb_target_group" "this" {
  name     = var.name
  port     = var.port
  protocol = var.protocol
  vpc_id   = var.vpc_id
}

resource "aws_lb_target_group_attachment" "test" {
  target_group_arn = aws_lb_target_group.this.arn
  target_id        = var.aws_instance_target_id
  port             = var.instance_target_group_port
}