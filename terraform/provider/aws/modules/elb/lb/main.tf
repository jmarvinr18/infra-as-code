resource "aws_lb" "this" {
  name               = var.name
  internal           = var.internal
  load_balancer_type = var.load_balancer_type
  security_groups    = var.security_groups
  subnets            = var.subnets

  enable_deletion_protection = var.enable_deletion_protection

  access_logs {
    bucket  = var.access_logs["bucket"]
    prefix  = var.access_logs["prefix"]
    enabled = var.access_logs["enabled"]
  }

  tags = var.tags
}