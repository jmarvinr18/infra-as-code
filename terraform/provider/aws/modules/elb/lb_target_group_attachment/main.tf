resource "aws_lb_target_group_attachment" "this" {
  target_group_arn = data.aws_lb_target_group.this.arn
  target_id        = var.aws_instance_target_id
  port             = var.instance_target_group_port
}