resource "aws_lb_listener" "this" {
  load_balancer_arn = var.load_balancer_arn
  port              = var.port
  protocol          = var.protocol
  ssl_policy        = var.port == "443" ? var.ssl_policy : null
  certificate_arn   = var.port == "443" ? var.certificate_arn : null

  default_action {
    
    type             = var.type
    target_group_arn = var.target_group_arn
    

    dynamic "redirect" {
      for_each = var.type == "redirect" ? [1] : []

      content {
        port        = var.redirect_port
        protocol    = var.redirect_protocol
        status_code = var.redirect_status_code        
      }
    }
  }
}